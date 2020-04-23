//
//  GFLoginViewController.swift
//  Genfare
//
//  Created by omniwzse on 29/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import FirebaseAuth

class GFLoginViewController: GFBaseViewController {
    
    @IBOutlet weak var codeTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    
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
    
    func addDoneButtonOnKeyboard() {
        
        return
        
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
