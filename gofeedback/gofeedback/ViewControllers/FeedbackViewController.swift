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
    
    var feedbackModel = FeedbackModel()
    var searchItem = ""
    var images : [UIImage]?
    var formImage : UIImage?
    var isImageFile = true
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        restuarantName.text = feedbackModel.restaurantTitle
        addressLabel.text = feedbackModel.address
        
        self.addDoneButtonOnKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        super.view.backgroundColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.ratingsUpadate()

    }
    @IBAction func cancelPressed(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func imagePressed(_ sender: UIButton) {
        
        self.isImageFile = true
       let imagePicker = OpalImagePickerController()
        imagePicker.imagePickerDelegate = self
        imagePicker.maximumSelectionsAllowed = 10
        let configuration = OpalImagePickerConfiguration()
        configuration.maximumSelectionsAllowedMessage = NSLocalizedString("You cannot select that many images!", comment: "")
        imagePicker.configuration = configuration
        present(imagePicker, animated: true, completion: nil)
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
            
             self.feedbackModel.comments = self.commentsTxt.text
            
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
                
                self.feedbackUpdate(userId)
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
    
    
    @IBAction func cameraPressed(_ sender: UIButton) {
        
       let  imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // will run if the user hits cancel
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            images?.append(pickedImage)
            
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

    func imagePickerDidCancel(_ picker: OpalImagePickerController) {
        // Cancel action
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingImages images: [UIImage]) {
        
        if isImageFile {
            
            self.imageBtn.isEnabled = false
            self.imageBtn.isHidden = true
            self.images = images
            picker.dismiss(animated: true, completion: nil)
        } else {
            
            self.formBtn.isEnabled = false
            self.formBtn.isHidden = true
            self.formImage = images[0]
            picker.dismiss(animated: true, completion: nil)
        }
        presentedViewController?.dismiss(animated: true, completion: nil)
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
}
