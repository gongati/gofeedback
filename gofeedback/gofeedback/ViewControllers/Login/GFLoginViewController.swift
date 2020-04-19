//
//  GFLoginViewController.swift
//  Genfare
//
//  Created by omniwzse on 29/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class GFLoginViewController: GFBaseViewController {
    
    @IBOutlet weak var codeTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    
    let db = Firestore.firestore()
    
    var userID: String?
    var loginId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginUser(_ sender: UIButton) {
        
        self.verifyPhone()
        self.attachSpinner(value: true)
    }
    
    
    func verifyPhone() {
        
        
        if let codeValue = self.codeTxt.text, codeValue.count > 0 {
            
            if let phoneValue = self.phoneTxt.text, phoneValue.count >= 10 {
                
                loginId = "+"+codeValue+" "+phoneValue
                
                let query = self.db.collection("Users").whereField(Constants.userDetails.mobileNumber, isEqualTo: self.loginId!)
                
                
                PhoneAuthProvider.provider().verifyPhoneNumber("+"+codeValue+phoneValue, uiDelegate: nil) { [weak self] (ID, err) in
                    
                    if err != nil{
                        
                        self?.popupAlert(title: "Error", message: err?.localizedDescription, actionTitles: ["OK"], actions: [nil])
                        return
                    }
                    
                    query.getDocuments() { (querySnapshot, err) in
                        
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            
                            if querySnapshot?.documents.count == 0 {
                                
                                self?.userID = ID!
                                self?.performSegue(withIdentifier: "REGISTER", sender: self?.userID)
                        
                            } else {
                                
                                print("query = \(querySnapshot?.documents)")
                                UserDefaults.standard.set((querySnapshot?.documents[0].data()[Constants.userDetails.firstName] as! String) + " " + (querySnapshot?.documents[0].data()[Constants.userDetails.lastName] as! String), forKey: "UserName")
                                
                                UserDefaults.standard.set((querySnapshot?.documents[0].data()[Constants.userDetails.email] as! String), forKey: "Email")
                                
                                UserDefaults.standard.set("\(querySnapshot?.documents[0].data()[Constants.userDetails.userType] as! Int)", forKey: "UserType")
                                
                                 UserDefaults.standard.synchronize()
                                self?.userID = ID!
                                self?.showOTPScreen()
                            }
                        }
                    }
                    
                }
                
                
            } else {
                
                self.popupAlert(title: "Error", message: "Invalid Phone Number", actionTitles: ["OK"], actions: [nil])
            }
            
        } else {
            
            self.popupAlert(title: "Error", message: "Code can not be empty", actionTitles: ["OK"], actions: [nil])
        }
    }
    
    func showOTPScreen() {
        
        self.performSegue(withIdentifier: "SHOWOTP", sender: self.userID)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        self.attachSpinner(value: false)
        
        if (segue.identifier == "SHOWOTP") {
            
            if let secondViewController = segue.destination as? GFOTPViewController {
                
                if let userId = sender as? String {
                    
                    secondViewController.userID = userId
                    secondViewController.loginId = loginId
                }
            }
        }
        if (segue.identifier == "REGISTER") {
            
            if let vc = segue.destination as? GFSignupViewController {
                
                if let userId = sender as? String {
                    
                    vc.userID = userId
                    vc.loginId = loginId
                    vc.mobileNumber = self.phoneTxt.text
                    vc.code = self.codeTxt.text
                }
            }
        }
    }
    
    func addDoneButtonOnKeyboard() {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        phoneTxt.inputAccessoryView = doneToolbar
        codeTxt.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        phoneTxt.resignFirstResponder()
        codeTxt.resignFirstResponder()
    }
}
