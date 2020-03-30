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

class FeedbackViewController: GFBaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var restuarantName: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var whatCanWeDoBetter: CosmosView!
    @IBOutlet weak var whatAreWeDoingGreat: CosmosView!
    @IBOutlet weak var howWeAreDoingCosmosView: CosmosView!
    @IBOutlet weak var commentsTxt: UITextView!
    @IBOutlet weak var cosmosView: CosmosView!
    
    @IBOutlet weak var imageBtn: UIButton!
    
    @IBOutlet weak var formBtn: UIButton!
    
    var restaurantTitle = ""
    var address = ""
    var rating : Double = 3
    var whatCanWeDoBetterRating: Double = 3
    var whatAreWeDoingGreatRating: Double = 3
    var howWeAreDoingRating: Double = 3

    var searchItem = ""
    let db = Firestore.firestore()
    var imageFileName = ""
    var formFilName = ""
    var isImageFile = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        restuarantName.text = restaurantTitle
        addressLabel.text = address
        
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
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func imagePressed(_ sender: UIButton) {
        
        self.isImageFile = true
        let picker = UIImagePickerController()
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func formPressed(_ sender: UIButton) {
        
        self.isImageFile = false
        let picker = UIImagePickerController()
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func submitPressed(_ sender: UIButton) {
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            self.feedbackUpdate(userId)
        } else {
            
            self.popupAlert(title: "Alert", message: "Please Login to give Feedback", actionTitles: ["OK"], actions: [{ action in
                
                self.navigationController?.popViewController(animated: true)
                }])
        }
        
    }
    
    func uploadImage(image: UIImage) {
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            let randomName = randomStringWithLength(length: 10)
            let imageData = image.jpegData(compressionQuality: 0.5)
            let path = "Images/\(userId)/\(restaurantTitle)/\(randomName).jpg"
            let uploadRef = Storage.storage().reference().child(path)
            _ = uploadRef.putData(imageData!, metadata: nil) { metadata,
                error in
                if error == nil {
                    //success
                    print("success")
                    self.imageFileName = path
                } else {
                    //error
                    print("error uploading image")
                }
            }
        }
    }
    
    
    func uploadForm(image: UIImage){
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            let randomName = randomStringWithLength(length: 10)
            let imageData = image.jpegData(compressionQuality: 0.5)
            let path = "Forms/\(userId)/\(restaurantTitle)/\(randomName).jpg"
            let uploadRef = Storage.storage().reference().child(path)
            _ = uploadRef.putData(imageData!, metadata: nil) { metadata,
                error in
                if error == nil {
                    //success
                    print("success")
                    self.formFilName = path
                } else {
                    //error
                    print("error uploading image")
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

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // will run if the user hits cancel
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            if isImageFile {
                
                self.imageBtn.isEnabled = false
                self.imageBtn.isHidden = true
                self.uploadImage(image: pickedImage)
                picker.dismiss(animated: true, completion: nil)
            } else {
                
                self.formBtn.isEnabled = false
                self.formBtn.isHidden = true
                self.uploadForm(image: pickedImage)
                picker.dismiss(animated: true, completion: nil)
            }
        }
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
    func ratingsUpadate() {
        
        
        cosmosView.didFinishTouchingCosmos = { rating in

            self.rating = rating
        }
        
        whatCanWeDoBetter.didFinishTouchingCosmos = { rating in
            
            self.whatCanWeDoBetterRating = rating
        }
        
        
        whatAreWeDoingGreat.didFinishTouchingCosmos = { rating in
            
            self.whatAreWeDoingGreatRating = rating
        }
        
        howWeAreDoingCosmosView.didFinishTouchingCosmos = { rating in
            
            self.howWeAreDoingRating = rating
        }
    }
    
    func feedbackUpdate(_ userId:String) {
        
        db.collection("Feedback").document(userId).collection("Ratings").document(self.restaurantTitle).setData([
            Constants.FeedbackCommands.restuarantName : self.restaurantTitle,
            Constants.FeedbackCommands.restuarantAddress : self.address,
            Constants.FeedbackCommands.howWeAreDoing : self.howWeAreDoingRating,
            Constants.FeedbackCommands.whatWeAreDoingGreat : self.whatAreWeDoingGreatRating,
            Constants.FeedbackCommands.whatCanWeDoBetter : self.whatCanWeDoBetterRating,
            Constants.FeedbackCommands.comments : self.commentsTxt.text,
            Constants.FeedbackCommands.rating : self.rating,
            Constants.FeedbackCommands.images : self.imageFileName,
            Constants.FeedbackCommands.form : self.formFilName
            
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
