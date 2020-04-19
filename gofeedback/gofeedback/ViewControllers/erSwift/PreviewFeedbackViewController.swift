//
//  PreviewFeedbackViewController.swift
//  gofeedback
//
//  Created by OMNIADMIN on 30/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class PreviewFeedbackViewController: GFBaseViewController {
    
    
  @IBOutlet weak var restuarantName: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var whatCanWeDoBetter: CosmosView!
    @IBOutlet weak var whatAreWeDoingGreat: CosmosView!
    @IBOutlet weak var howWeAreDoingCosmosView: CosmosView!
    @IBOutlet weak var commentsTxt: UITextView!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var submitBtnOulet: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var imageStackView: UIStackView!
  
    @IBOutlet weak var adminApprove: UIButton!
    @IBOutlet weak var adminRejecect: UIButton!
    
    var feedbackModel = FeedbackModel()
    var images:[UIImage]?
    var formImage:UIImage?
    var videoUrl:[URL]?
    var videoTag:[Int]?
    var adminUserId:String?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.UIUpdate()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        super.view.backgroundColor = UIColor.white
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
        navigationController?.removeFromParent()
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        
        if let userID =  UserDefaults.standard.string(forKey: "UserId") {
            
            self.attachSpinner(value: true)
            if self.feedbackModel.status == .Drafts {
                
                db.collection("Feedback").document(userID).collection(self.feedbackModel.status.rawValue).document(self.feedbackModel.restaurantTitle).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
            }
            
            self.feedbackModel.status = .Submitted
            
            if   self.images?.count != 0 &&  self.videoUrl?.count != 0 {
                
                self.feedbackModel.videoFilName.removeAll()
                if let videoUrl = self.videoUrl {
                    
                    for url in 0..<videoUrl.count {
                        
                        self.uploadVideo(videoUrl[url], url)
                    }
                }
            }  else if  self.images?.count != 0 {
                
                self.feedbackModel.imageFileName.removeAll()
                if let images = self.images {
                    outer: for image in 0..<images.count {
                        
                        for tag in self.videoTag ?? [-1] {
                            
                            if image == tag  {
                                
                               self.uploadImage(image: images[image],image,tag)
                                continue outer
                            }
                        }
                        self.uploadImage(image: images[image],image,nil)
                    }
                }
            } else {
                
                self.feedbackUpdate(userID,self.feedbackModel.status.rawValue, nil)
            }
            
        } else {
            
            self.popupAlert(title: "Alert", message: "Please Login to give Feedback", actionTitles: ["OK"], actions: [{ action in
                
                self.navigationController?.popViewController(animated: true)
                }])
        }
        
    }
    
    @IBAction func approvedPressed(_ sender: UIButton) {
        
        self.feedbackModel.status = .Paid
        
        if let userid = self.adminUserId {
            
            self.feedbackUpdate(userid,FeedbackStatus.Submitted.rawValue, "Approved")
        }
    }
    
    
    @IBAction func rejectedPressed(_ sender: UIButton) {
     
        self.feedbackModel.status = .Rejected
        
         if let userid = self.adminUserId {
             
            self.feedbackUpdate(userid,FeedbackStatus.Submitted.rawValue, "Rejected")
         }
    }
    
    func moveToHomeVC() {
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    func moveToFeedback() {
        
        guard let viewController = UIStoryboard(name: "Feedback", bundle: nil).instantiateViewController(withIdentifier:  "GFNAVIGATETOLOGIN") as? GFLoginViewController else {
                   return
               }
               self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func feedbackUpdate(_ userId:String, _ status: String,_ messageData:String?) {
        
        db.collection("Feedback").document(userId).collection(status).document(self.feedbackModel.restaurantTitle).setData([
            Constants.FeedbackCommands.restuarantName : self.feedbackModel.restaurantTitle,
            Constants.FeedbackCommands.restuarantAddress : self.feedbackModel.address,
            Constants.FeedbackCommands.howWeAreDoing : self.feedbackModel.howWeAreDoingRating,
            Constants.FeedbackCommands.whatWeAreDoingGreat : self.feedbackModel.whatAreWeDoingGreatRating,
            Constants.FeedbackCommands.whatCanWeDoBetter : self.feedbackModel.whatCanWeDoBetterRating,
            Constants.FeedbackCommands.comments : self.feedbackModel.comments,
            Constants.FeedbackCommands.rating : self.feedbackModel.rating,
            Constants.FeedbackCommands.images : self.feedbackModel.imageFileName,
            Constants.FeedbackCommands.form : self.feedbackModel.formFilName,
            Constants.FeedbackCommands.status : self.feedbackModel.status.rawValue,
            Constants.FeedbackCommands.videoUrl : self.feedbackModel.videoFilName,
            Constants.FeedbackCommands.thumnailTag
               : self.feedbackModel.thumnail
            
        ]) { (error) in
            
            self.attachSpinner(value: false)
            if let err = error {
                self.popupAlert(title: "Error", message: err.localizedDescription, actionTitles: ["OK"], actions: [nil])
            } else {
                
                if let messageData = messageData {
                    
                 self.popupAlert(title: "Alert", message: messageData, actionTitles: ["OK"], actions: [{ action in
                                    
                    self.navigationController?.popViewController(animated: true)
                                }])
                } else {
                print("Successfully saved data.")
                self.popupAlert(title: "Alert", message: "Successfully saved data.", actionTitles: ["OK"], actions: [{ action in
                    
                    self.moveToHomeVC()
                }])
                }
           }
        }
    }
    
    
    func uploadImage(image: UIImage,_ value : Int , _ tag:Int?) {
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
         
            let group = DispatchGroup()
            let randomName = randomStringWithLength(length: 10)
            let imageData = image.jpegData(compressionQuality: 0.1)
            let path = "Images/\(userId)/\(feedbackModel.restaurantTitle)/\(randomName).jpg"
            let uploadRef = Storage.storage().reference().child(path)
            _ = uploadRef.putData(imageData!, metadata: nil) { metadata,
                error in
                group.enter()
                if error == nil {
                    //success
                    print("success\(path)")
                    
                    if tag != nil {
                        
                        self.feedbackModel.thumnail.removeAll()
                        self.feedbackModel.thumnail.append(path)
                        
                    }
                    self.feedbackModel.imageFileName.append(path)
                } else {
                    //error
                    print("error uploading image")
                }
                
                if value == ((self.images?.count ?? 0) - 1) {
                    
                    self.feedbackUpdate(userId,self.feedbackModel.status.rawValue, nil)
                }
            }
        }
    }
    
    func randomStringWithLength(length: Int) -> NSString {
        
        let characters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString: NSMutableString = NSMutableString(capacity: length)

        for _ in 0..<length {
            let len = UInt32(characters.length)
            let rand = arc4random_uniform(len)
            randomString.appendFormat("%C", characters.character(at: Int(rand)))
        }
        return randomString
    }
    
    func UIUpdate() {
        
        restuarantName.text = feedbackModel.restaurantTitle
        addressLabel.text = feedbackModel.address
        cosmosView.rating = feedbackModel.rating
        whatCanWeDoBetter.rating = feedbackModel.whatCanWeDoBetterRating
        whatAreWeDoingGreat.rating = feedbackModel.whatAreWeDoingGreatRating
        howWeAreDoingCosmosView.rating = feedbackModel.howWeAreDoingRating
        commentsTxt.text = feedbackModel.comments
        
        if let images = self.images {
            for subview in images {
                let imageButton = UIButton()
                imageButton.addTarget(self, action: #selector(self.imageButtonPressed(sender:)), for: .touchUpInside)
                imageButton.setImage(subview, for: .normal)
                imageButton.tag = subview.hashValue
                
                imageButton.snp.makeConstraints { (make) in
                    
                    make.height.equalTo(self.imageStackView.frame.height)
                    make.width.equalTo(120)
                }
                self.imageStackView.addArrangedSubview(imageButton)
                
                self.imageStackView.translatesAutoresizingMaskIntoConstraints = false
            }
            self.scrollView.contentSize = CGSize(width: self.imageStackView.frame.width + 130, height: self.scrollView.frame.height)
        }
        if feedbackModel.isSubmitBtnHidden {
            
            submitBtnOulet.isHidden = true
        }
        if feedbackModel.isApprovedBtnHidden && feedbackModel.isRejectbtnHidden {
            
            adminApprove.isHidden = true
            adminRejecect.isHidden = true
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        
        performSegue(withIdentifier: "ImageView", sender: sender.imageView?.image)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ImageView" {
            
            
            let vc = segue.destination as! PreviewImageViewController
            
            vc.image = sender as? UIImage
            
            if let sender = sender as? URL {
                
                vc.videoUrl = sender
                vc.isVideo = true
            }
        }
        
    }
    
    func uploadVideo(_ url:URL, _ value:Int) {
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            var data : Data?
            let randomName = randomStringWithLength(length: 10)
            do {
              data = try Data(contentsOf: url as URL)
            } catch {

                print(error)
            }

            let path = "Videos/\(userId)/\(feedbackModel.restaurantTitle)/\(randomName).mov"
            let uploadRef = Storage.storage().reference().child(path)
          
            _ = uploadRef.putData(data!, metadata: nil) { metadata,
                error in
                if error == nil {
                    //success
                    print("success \(path)")
                    self.feedbackModel.videoFilName.append(path)
                    
                } else {
                    //error
                    print("error uploading image")
                }
                if value == ((self.videoUrl?.count ?? 0) - 1) {
                    if let images = self.images {
                        self.feedbackModel.imageFileName.removeAll()
                        outer: for image in 0..<images.count {
                            
                            for tag in self.videoTag ?? [-1] {
                                
                                if image == tag  {
                                    
                                    self.uploadImage(image: images[image],image,tag)
                                    continue outer
                                }
                            }
                            self.uploadImage(image: images[image],image,nil)
                        }
                    } else {
                        self.feedbackUpdate(userId,self.feedbackModel.status.rawValue, nil)
                    }
                }
            }
        }
    }
    
  
    @objc func imageButtonPressed(sender: UIButton) {
        
        if let images = self.images {
            
            for i in 0..<images.count {
                
                if sender.tag == images[i].hashValue {
                    
                    if  self.videoTag?.count != 0 {
                        
                        for j in 0..<(self.videoTag?.count ?? 0) {
                            
                            if i == self.videoTag?[j] {
                                
                                performSegue(withIdentifier: "ImageView", sender: self.videoUrl?[j])
                                return
                            }
                        }
                        performSegue(withIdentifier: "ImageView", sender: sender.imageView?.image)
                    } else {
                        
                        performSegue(withIdentifier: "ImageView", sender: sender.imageView?.image)
                    }
                }
            }
        }
    }
}
