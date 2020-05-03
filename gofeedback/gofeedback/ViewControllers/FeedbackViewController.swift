//
//  ViewController.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 04/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import  Cosmos
import Photos
import YPImagePicker
import CDYelpFusionKit

class FeedbackViewController: GFBaseViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var restuarantName: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var whatCanWeDoBetter: CosmosView!
    @IBOutlet weak var whatAreWeDoingGreat: CosmosView!
    @IBOutlet weak var howWeAreDoingCosmosView: CosmosView!
    @IBOutlet weak var commentsTxt: UITextView!
    @IBOutlet weak var cosmosView: CosmosView!
    
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
    var videoPath = [String]()
    var imageFileName = [String]()
    var videoFilName = [String]()
    var bussiness: CDYelpBusiness?
    var isReceiptBtnEnabled = false
    
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
        
        self.commentsTxt.layer.borderColor = UIColor.lightGray.cgColor
        self.commentsTxt.layer.borderWidth = 1
        self.commentsTxt.layer.cornerRadius = 5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.ratingsUpadate()

    }
    
    
    @IBAction func submitPressed(_ sender: UIButton) {
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            self.attachSpinner(value: true)
            
            self.feedbackModel.status = .Submitted
            self.feedbackModel.price = 0.0
            self.feedbackModel.restaurentImageUrl = self.bussiness?.imageUrl
            
             self.feedbackModel.comments = self.commentsTxt.text
            
            if  images.count != 0 && videoUrl.count != 0 {
                
                self.videoFilName.removeAll()
                for url in 0..<videoUrl.count {
                    
                    self.uploadVideo(videoUrl[url],url)
                }
            } else if images.count != 0 {
                
                self.imageFileName.removeAll()
                outer: for image in 0..<images.count {
                    
                    for tag in self.thumnailTag {
                        
                        if image == tag  {
                            
                            self.uploadImage(image: images[image],image,tag)
                            continue outer
                        }
                    }
                    self.uploadImage(image: images[image],image,nil)
                }
            } else {
                
                self.feedbackUpdate(userId)
            }
        } else {
            
            self.popupAlert(title: "Alert", message: "Please Login to give Feedback", actionTitles: ["OK"], actions: [{ action in
                
                self.navigationController?.popViewController(animated: true)
                }])
        }
        
    }
    
    
    @IBAction func draftPressed(_ sender: UIButton) {
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            self.attachSpinner(value: true)
            
            self.feedbackModel.status = .Drafts
            self.feedbackModel.price = 0.0
            self.feedbackModel.restaurentImageUrl = self.bussiness?.imageUrl
            
             self.feedbackModel.comments = self.commentsTxt.text
            
            if  images.count != 0 && videoUrl.count != 0 {
                
                self.videoFilName.removeAll()
                for url in 0..<videoUrl.count {
                    
                    self.uploadVideo(videoUrl[url],url)
                }
            } else if images.count != 0 {
                
                self.imageFileName.removeAll()
                outer: for image in 0..<images.count {
                    
                      for tag in self.thumnailTag {
                        
                        if image == tag  {
                            
                            self.uploadImage(image: images[image],image,tag)
                            continue outer
                        }
                    }
                    self.uploadImage(image: images[image],image,nil)
                }
            } else {
                
                self.feedbackUpdate(userId)
            }
        } else {
            
            self.popupAlert(title: "Alert", message: "Please Login to saved to drafts", actionTitles: ["OK"], actions: [{ action in
                
                self.navigationController?.popViewController(animated: true)
                }])
        }
    }
    
    let dispatchGroup = DispatchGroup()
    func uploadImage(image: UIImage, _ value:Int, _ tag:Int?) {
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            dispatchGroup.enter()
            let randomName = randomStringWithLength(length: 10)
            var path = ""
            if tag == nil {
                path = "Images/\(userId)/\(feedbackModel.restaurantTitle)/\(randomName).jpg"
            } else {
                let path2 = self.videoPath[tag!]
                path = "Images/"+path2+".jpg"
            }
            GFFirebaseManager.uploadImage(image: image, path) { (value) in
                
                if value {
                    
                    print("success \(path)")
                    self.imageFileName.append(path)
                } else {
        
                    print("error uploading image")
                }
                
                self.dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main) {
                
                if value == (self.images.count - 1) {
                    
                    self.feedbackUpdate(userId)
                }
            }
        }
    }
    
    
    @IBAction func cameraPressed(_ sender: UIButton) {
        
        self.openCamera()
    }
    
    
    @IBAction func receiptBtnPressed(_ sender: UIButton) {
        
        isReceiptBtnEnabled = !isReceiptBtnEnabled
        
        if isReceiptBtnEnabled {
            
            sender.setImage(UIImage(named: "checkBox"), for: .normal)
        } else {
            
            sender.setImage(UIImage(named: "unchecked-image"), for: .normal)
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
    
    func feedbackUpdate(_ userId:String) {
        
        self.feedbackModel.userId = userId
        self.feedbackModel.videoFilName = self.videoFilName
        self.feedbackModel.imageFileName = self.imageFileName
        let timestamp = Date().timeIntervalSince1970
        self.feedbackModel.timeStamp = timestamp
        self.feedbackModel.isReceiptAttached = isReceiptBtnEnabled
        
        GFFirebaseManager.creatingFeedBack(feedbackModel: self.feedbackModel) { (value) in
            
            if value {
                print("Successfully saved data.")
                self.attachSpinner(value: false)
                self.popupAlert(title: "Alert", message: "Successfully saved data.", actionTitles: ["OK"], actions: [{ action in
                    
                    self.navigationController?.popViewController(animated: true)
                    }])
            } else {
                self.popupAlert(title: "Error", message: "Error in saving Feedback", actionTitles: ["OK"], actions: [nil])
            }
            
            self.attachSpinner(value: false)
        }
    }
    
    let group = DispatchGroup()
    
    func uploadVideo(_ url:URL,_ value:Int) {
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            group.enter()
            let randomName = randomStringWithLength(length: 10)
            
            let path = "Videos/\(userId)/\(feedbackModel.restaurantTitle)/\(randomName).mov"
            videoPath.append("\(userId)/\(feedbackModel.restaurantTitle)/\(randomName)")
            
            GFFirebaseManager.uploadVideo(url: url, path) { (value) in
                
                if value {
                    
                    print("success \(path)")
                    self.videoFilName.append(path)
                } else {
                    
                    print("error uploading video")
                }
                self.group.leave()
            }
            
            group.notify(queue: DispatchQueue.main) {
                
                if value == (self.videoUrl.count - 1) {
                    if self.images.count != 0 {
                        self.imageFileName.removeAll()
                        outer: for image in 0..<self.images.count {
                            
                            for tag in self.thumnailTag {
                                
                                if image == tag  {
                                    
                                    self.uploadImage(image: self.images[image],image,tag)
                                    continue outer
                                }
                            }
                            self.uploadImage(image: self.images[image],image,nil)
                        }
                    } else {
                        self.feedbackUpdate(userId)
                    }
                }
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
}
