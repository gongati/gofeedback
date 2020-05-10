//
//  GFLoginViewController.swift
//  Genfare
//
//  Created by omniwzse on 29/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import FirebaseAuth

class GFLoginViewController: GFBaseViewController,UITextFieldDelegate {
    
    @IBOutlet weak var codeTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var signInBtn: UIButton!

    var userID: String?
    var loginId:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.codeTxt.delegate = self
        self.phoneTxt.delegate = self
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
    
                PhoneAuthProvider.provider().verifyPhoneNumber("+"+codeValue+phoneValue, uiDelegate: nil) { [weak self] (ID, err) in
                    
                    if err != nil{
                        
                        self?.popupAlert(title: "Error", message: err?.localizedDescription, actionTitles: ["OK"], actions: [nil])
                        self?.attachSpinner(value: false)
                        return
                    }
                    
                    GFFirebaseManager.isUserHasRegistered(userId: self?.loginId! ?? "") { (value) in
                        
                        self?.userID = ID!
                        if value {
                            
                            self?.performSegue(withIdentifier: "REGISTER", sender: self?.userID)
                        } else {
                            
                            self?.showOTPScreen()
                        }
                    }
                }
            } else {
                
                self.attachSpinner(value: false)
                self.popupAlert(title: "Error", message: "Invalid Phone Number", actionTitles: ["OK"], actions: [nil])
            }
        } else {
            
            self.attachSpinner(value: false)
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
    
    @objc override func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let frame = (self.view.frame.height - (self.phoneTxt.frame.origin.y + self.phoneTxt.frame.height))
            if  frame <  keyboardSize.height {
                
                self.view.frame.origin.y -= (keyboardSize.height - frame) + 10
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.codeTxt {
            
            phoneTxt.becomeFirstResponder()
        } else {
            
            textField.resignFirstResponder()
        }
        return true
    }
}
