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
    @IBOutlet weak var imagesStackView: UIStackView!
    @IBOutlet weak var formImageView: UIImageView!
    
    var feedbackModel = FeedbackModel()
    var images:[UIImage]?
    var formImage:UIImage?
    
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
            
            if let _ = images, let form = formImage{
                
                self.uploadForm(image: form)
            } else if let form = self.formImage {
                
                self.uploadForm(image: form)
            } else if let images = images {
                self.feedbackModel.imageFileName.removeAll()
                for image in images {
                self.uploadImage(image: image)
                }
            } else {
                
                self.feedbackUpdate(userID)
            }
            
        } else {
            
            self.popupAlert(title: "Alert", message: "Please Login to give Feedback", actionTitles: ["OK"], actions: [{ action in
                
                self.navigationController?.popViewController(animated: true)
                }])
        }
        
    }
    
    @IBAction func imagesView(_ sender: UIButton) {
        
        
    }
    
    @IBAction func formView(_ sender: UIButton) {
        
        if let form = formImage {
            
            self.showImage(form, "Form")
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
    
    func feedbackUpdate(_ userId:String) {
        
        db.collection("Feedback").document(userId).collection("Ratings").document(self.feedbackModel.restaurantTitle).setData([
            Constants.FeedbackCommands.restuarantName : self.feedbackModel.restaurantTitle,
            Constants.FeedbackCommands.restuarantAddress : self.feedbackModel.address,
            Constants.FeedbackCommands.howWeAreDoing : self.feedbackModel.howWeAreDoingRating,
            Constants.FeedbackCommands.whatWeAreDoingGreat : self.feedbackModel.whatAreWeDoingGreatRating,
            Constants.FeedbackCommands.whatCanWeDoBetter : self.feedbackModel.whatCanWeDoBetterRating,
            Constants.FeedbackCommands.comments : self.feedbackModel.comments,
            Constants.FeedbackCommands.rating : self.feedbackModel.rating,
            Constants.FeedbackCommands.images : self.feedbackModel.imageFileName,
            Constants.FeedbackCommands.form : self.feedbackModel.formFilName
        ]) { (error) in
            if let err = error {
                self.popupAlert(title: "Error", message: err.localizedDescription, actionTitles: ["OK"], actions: [nil])
            } else {
                print("Successfully saved data.")
                self.popupAlert(title: "Alert", message: "Successfully saved data.", actionTitles: ["OK"], actions: [{ action in
                    
                    self.moveToHomeVC()
                }])
           }
        }
    }
    
    func showImage(_ image:UIImage,_ title:String) {
        
        let showAlert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let imageView = UIImageView(frame: CGRect(x: 10, y: 50, width: 250, height: 230))
        imageView.image = image
        showAlert.view.addSubview(imageView)
        let height = NSLayoutConstraint(item: showAlert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
        let width = NSLayoutConstraint(item: showAlert.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        showAlert.view.addConstraint(height)
        showAlert.view.addConstraint(width)
        showAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(showAlert, animated: true, completion: nil)
    }
    
    func uploadImage(image: UIImage) {
        
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
                    self.feedbackModel.imageFileName.append(path)
                } else {
                    //error
                    print("error uploading image")
                }
                self.feedbackUpdate(userId)
            }
        }
    }
    
    
    func uploadForm(image: UIImage){
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            let randomName = randomStringWithLength(length: 10)
            let imageData = image.jpegData(compressionQuality: 0.1)
            let path = "Forms/\(userId)/\(feedbackModel.restaurantTitle)/\(randomName).jpg"
            let uploadRef = Storage.storage().reference().child(path)
            
            _ = uploadRef.putData(imageData!, metadata: nil) { metadata,
                error in
                if error == nil {
                    //success
                    print("success \(path)")
                    self.feedbackModel.formFilName = path
                } else {
                    //error
                    print("error uploading image")
                }
                if let images = self.images {
                    self.feedbackModel.imageFileName.removeAll()
                    for image in images {
                    self.uploadImage(image: image)
                    }
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
        formImageView.image = formImage
        formImageView.contentMode = .scaleAspectFit
        
        if let images = self.images {
        for image in images {
            
          let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
        imagesStackView.addArrangedSubview(imageView)
            imagesStackView.translatesAutoresizingMaskIntoConstraints = false
        }
        }
        if feedbackModel.isSubmitBtnHidden {
            
            submitBtnOulet.isHidden = true
        }
        
        
    }
}
