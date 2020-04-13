//
//  ViewController.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 04/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import  Cosmos
import Firebase
import OpalImagePicker
import Photos
import YPImagePicker
import CDYelpFusionKit

class FeedbackViewController: GFBaseViewController, OpalImagePickerControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var restuarantName: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var whatCanWeDoBetter: CosmosView!
    @IBOutlet weak var whatAreWeDoingGreat: CosmosView!
    @IBOutlet weak var howWeAreDoingCosmosView: CosmosView!
    @IBOutlet weak var commentsTxt: UITextView!
    @IBOutlet weak var cosmosView: CosmosView!
    
    @IBOutlet weak var imageBtn: UIButton!

    @IBOutlet weak var formBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var headerImageView: UIImageView!
    
    var feedbackModel = FeedbackModel()

    var searchItem = ""
    var images = [UIImage]()
    var videoUrl = [URL]()
    var formImage : UIImage?
    var isImageFile = true
    var stackImageView = [UIImageView]()
    var videoTag = [Int]()
    var thumnailTag = [Int]()
    
    let db = Firestore.firestore()
    var imageFileName = ""
    var formFilName = ""
    var bussiness: CDYelpBusiness?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.restuarantName.text = feedbackModel.restaurantTitle
        self.addressLabel.text = feedbackModel.address
        if let bimages = self.bussiness?.photos, bimages.count > 0 {
            
            self.headerImageView.downloaded(from: bimages[0], contentMode: .scaleAspectFill)
        } else {
            self.headerImageView.downloaded(from: self.bussiness?.imageUrl?.absoluteString ?? "", contentMode: .scaleAspectFill)
        }
        
        self.addDoneButtonOnKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        super.view.backgroundColor = UIColor.white
        self.cameraButton.layer.cornerRadius = 10
        self.cameraButton.layer.borderWidth = 1
        self.cameraButton.contentMode = .scaleAspectFit
        self.cameraButton.layer.borderColor = UIColor.black.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.ratingsUpadate()

    }
    @IBAction func cancelPressed(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func formPressed(_ sender: UIButton) {
        
        self.isImageFile = false
        let imagePicker = OpalImagePickerController()
        imagePicker.imagePickerDelegate = self
        imagePicker.maximumSelectionsAllowed = 1
        let configuration = OpalImagePickerConfiguration()
        configuration.maximumSelectionsAllowedMessage = NSLocalizedString("You cannot select more than one images!", comment: "")
        imagePicker.configuration = configuration
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func submitPressed(_ sender: UIButton) {
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            self.feedbackModel.status = .Submitted
            
             self.feedbackModel.comments = self.commentsTxt.text
            
            if  images.count != 0 && videoUrl.count != 0 {
                
                self.feedbackModel.videoFilName.removeAll()
                for url in videoUrl {
                    
                    self.uploadVideo(url)
                }
            } else if self.videoUrl.count != 0 {
                
                self.feedbackModel.videoFilName.removeAll()
                for url in videoUrl {
                    
                    self.uploadVideo(url)
                }
            } else if images.count != 0 {
                
                self.feedbackModel.imageFileName.removeAll()
                for image in 0..<images.count {
                    
                    for tag in self.thumnailTag {
                        
                        if image == tag  {
                            
                            self.uploadImage(image: images[image],tag)
                        } 
                        self.uploadImage(image: images[image],nil)
                    }
                }
            } else {
                
                self.feedbackUpdate(userId,self.feedbackModel.status.rawValue)
            }
        } else {
            
            self.popupAlert(title: "Alert", message: "Please Login to give Feedback", actionTitles: ["OK"], actions: [{ action in
                
                self.navigationController?.popViewController(animated: true)
                }])
        }
        
    }
    
    @IBAction func previewPressed(_ sender: UIButton) {
        
        self.feedbackModel.comments = self.commentsTxt.text
        self.moveToPreview()
    }
    
    @IBAction func draftPressed(_ sender: UIButton) {
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            self.feedbackModel.status = .Drafts
            
             self.feedbackModel.comments = self.commentsTxt.text
            
            if  images.count != 0 && videoUrl.count != 0 {
                
                self.feedbackModel.videoFilName.removeAll()
                for url in videoUrl {
                    
                    self.uploadVideo(url)
                }
            } else if self.videoUrl.count != 0 {
                
                self.feedbackModel.videoFilName.removeAll()
                for url in videoUrl {
                    
                    self.uploadVideo(url)
                }
            } else if images.count != 0 {
                
                self.feedbackModel.imageFileName.removeAll()
               for image in 0..<images.count {
                    
                    for tag in self.thumnailTag {
                        
                        if image == tag  {
                            
                            self.uploadImage(image: images[image],tag)
                        }
                        self.uploadImage(image: images[image],nil)
                    }
                }
            } else {
                
                self.feedbackUpdate(userId,self.feedbackModel.status.rawValue)
            }
        } else {
            
            self.popupAlert(title: "Alert", message: "Please Login to saved to drafts", actionTitles: ["OK"], actions: [{ action in
                
                self.navigationController?.popViewController(animated: true)
                }])
        }
    }
    
    
    func uploadImage(image: UIImage, _ tag:Int?) {
        
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
                    if let tag = tag {
                        
                        self.feedbackModel.thumnail.append(path)
                        
                    }
                    self.feedbackModel.imageFileName.append(path)
                } else {
                    //error
                    print("error uploading image")
                    print(error)
                }
                
               self.feedbackUpdate(userId,self.feedbackModel.status.rawValue)

            }
                
        }
    }
    
    
    @IBAction func cameraPressed(_ sender: UIButton) {
        
        self.openCamera()
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
    
    func addDoneButtonOnKeyboard(){
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        commentsTxt.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        whatCanWeDoBetter.resignFirstResponder()
        whatAreWeDoingGreat.resignFirstResponder()
        howWeAreDoingCosmosView.resignFirstResponder()
        commentsTxt.resignFirstResponder()
    }
    
    func moveToHomeVC() {
        
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "GFNAVIGATEMENUHOME") as? HomeViewController else {
            return
        }
        viewController.searchItem = searchItem
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    func moveToLogin() {
        
        guard let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier:  "GFNAVIGATETOLOGIN") as? GFLoginViewController else {
                   return
               }
               self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func moveToPreview() {
        
        guard let viewController = UIStoryboard(name: "Feedback", bundle: nil).instantiateViewController(withIdentifier:  "PreviewFeedbackViewController") as? PreviewFeedbackViewController else {
            return
        }
        viewController.feedbackModel = feedbackModel
        viewController.images = self.images
        viewController.formImage = self.formImage
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func ratingsUpadate() {
        
        
        cosmosView.didFinishTouchingCosmos = { rating in

            self.feedbackModel.rating = rating
        }
        
        whatCanWeDoBetter.didFinishTouchingCosmos = { rating in
            
            self.feedbackModel.whatCanWeDoBetterRating = rating
        }
        
        
        whatAreWeDoingGreat.didFinishTouchingCosmos = { rating in
            
            self.feedbackModel.whatAreWeDoingGreatRating = rating
        }
        
        howWeAreDoingCosmosView.didFinishTouchingCosmos = { rating in
            
            self.feedbackModel.howWeAreDoingRating = rating
        }
    }
    
    func feedbackUpdate(_ userId:String, _ status:String) {
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
}


extension FeedbackViewController {
    
    func configureCamera() -> YPImagePickerConfiguration {
        
        var config = YPImagePickerConfiguration()
        config.library.onlySquare = false
        config.library.mediaType = YPlibraryMediaType.photoAndVideo
        config.onlySquareImagesFromCamera = false
        config.targetImageSize = .original
        config.usesFrontCamera = true
        config.shouldSaveNewPicturesToAlbum = true
        config.video.compression = AVAssetExportPresetHighestQuality
        config.albumName = "MyGreatAppName"
        config.screens = [.photo, .video, .library]
        config.startOnScreen = .photo
        config.video.recordingTimeLimit = 10
        config.video.libraryTimeLimit = 20
        config.showsCrop = .rectangle(ratio: (16/9))
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false
        config.showsPhotoFilters = false
        config.showsCrop = .none
        config.wordings.next = "Select"
        
        //config.overlayView = myOverlayView

        return config
    }
    
    func openCamera() {
        
        let picker = YPImagePicker(configuration: configureCamera())

        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            if self.imageStackView.subviews.count > 0 {
                
                for subview in self.imageStackView.subviews {
                    
                    subview.removeFromSuperview()
                }
            }
            
            self.imageStackView.addArrangedSubview(self.cameraButton)
            for item in items {
                
                let images = UIImageView()
                switch item {
                case .photo(let photo):
                    self.images.append(photo.image)
                    images.image = (photo.image)
                    self.stackImageView.append(images)
                    print(photo)
                case .video(let video):
                    print(video.thumbnail)
                    self.videoUrl.append(video.url)
                    self.images.append(video.thumbnail)
                    self.thumnailTag.append(self.images.count - 1)
                    images.image = (video.thumbnail)
                    self.stackImageView.append(images)
                    self.videoTag.append(self.stackImageView[self.stackImageView.count - 1].hashValue)
                }
    
                for subview in self.stackImageView {
                    
                    let imageButton = UIButton()
                    imageButton.addTarget(self, action: #selector(self.imageButtonPressed(sender:)), for: .touchUpInside)
                    imageButton.setImage(subview.image, for: .normal)
                    imageButton.tag = subview.hashValue
                    
                    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                    button.setImage(UIImage(named: "Delete"), for: .normal)
                    button.addTarget(self, action: #selector(self.imageDeletePressed(sender:)), for: .touchUpInside)
                    button.tag = subview.hashValue
                    imageButton.addSubview(button)
                    button.snp.makeConstraints { (make) in
                        
                        make.top.equalToSuperview()
                        make.trailing.equalToSuperview()
                        make.height.equalTo(30)
                        make.width.equalTo(30)
                    }
                    
                    imageButton.snp.makeConstraints { (make) in
                        
                        make.height.equalTo(self.imageStackView.frame.height)
                        make.width.equalTo(120)
                    }
                    
                    self.imageStackView.addArrangedSubview(imageButton)
                    
                    self.imageStackView.translatesAutoresizingMaskIntoConstraints = false
                }
                
                self.scrollView.contentSize = CGSize(width: self.imageStackView.frame.width + 130, height: self.scrollView.frame.height)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        self.present(picker, animated: true, completion: nil)
    }
    
    @objc func imageDeletePressed(sender: UIButton) {
        
        var i = 0
        while i<self.stackImageView.count {
            
            if sender.tag == self.stackImageView[i].hashValue {
                
                self.imageStackView.subviews[i+1].removeFromSuperview()
                self.stackImageView.remove(at: i)
            }
            i += 1
        }
        
    }
    
    @objc func imageButtonPressed(sender: UIButton) {
        
        for i in 0..<self.stackImageView.count {
            
            if sender.tag == self.stackImageView[i].hashValue {
                
                if  self.videoTag.count != 0 {
                    
                    for j in 0..<self.videoTag.count {
                        
                        if sender.tag == self.videoTag[j] {
                            
                            performSegue(withIdentifier: "FeedbackPreviewImage", sender: self.videoUrl[j])
                        }
                    }
                } else {
                
                 performSegue(withIdentifier: "FeedbackPreviewImage", sender: sender.imageView?.image)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "FeedbackPreviewImage" {
            
            
            let vc = segue.destination as! PreviewImageViewController
            
            vc.image = sender as? UIImage
            
            if let sender = sender as? URL {
                
                vc.videoUrl = sender
                vc.isVideo = true
            }
            
        }
        
    }
    
    func uploadVideo(_ url:URL) {
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            let randomName = randomStringWithLength(length: 10)

            let path = "Videos/\(userId)/\(feedbackModel.restaurantTitle)/\(randomName).mov"
            let uploadRef = Storage.storage().reference().child(path)
          
            
            _ = uploadRef.putFile(from: url, metadata: nil) { metadata, error in
            
                if error == nil {
                    //success
                        
                        print("success \(path)")
                        self.feedbackModel.videoFilName.append(path)
                        
                } else {
                    //error
                    print("error uploading video")
                    print(error)
                }
                if self.images.count != 0 {
                    self.feedbackModel.imageFileName.removeAll()
                    for image in 0..<self.images.count {
                        
                        for tag in self.thumnailTag {
                            
                            if image == tag  {
                                
                                self.uploadImage(image: self.images[image],tag)
                            }
                            self.uploadImage(image: self.images[image],nil)
                        }
                    }
                } else {
                self.feedbackUpdate(userId,self.feedbackModel.status.rawValue)
                }
            }
        }
    }
}

extension Array {
    mutating func move(at index: Index, to newIndex: Index) {
        insert(remove(at: index), at: newIndex)
    }
}
