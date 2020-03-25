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
    @IBOutlet weak var registerBtn: UIButton!
    
    var userID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.addDoneButtonOnKeyboard()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
    
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginUser(_ sender: UIButton) {
        
        self.verifyPhone()
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "REGISTER", sender: self)
    }
    
    func verifyPhone() {
        
        if let codeValue = self.codeTxt.text, codeValue.count > 1 {
            
            if let phoneValue = self.phoneTxt.text, phoneValue.count >= 10 {
                
                PhoneAuthProvider.provider().verifyPhoneNumber("+"+codeValue+phoneValue, uiDelegate: nil) { [weak self] (ID, err) in
                    
                    if err != nil{
                        
                        self?.popupAlert(title: "Error", message: err?.localizedDescription, actionTitles: ["OK"], actions: [nil])
                        return
                    }
                    
                    self?.userID = ID!
                    self?.showOTPScreen()
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
        
        if (segue.identifier == "SHOWOTP") {
            
            if let secondViewController = segue.destination as? GFOTPViewController {
                
                if let userId = sender as? String {
                    
                    secondViewController.userID = userId
                }
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

        phoneTxt.inputAccessoryView = doneToolbar
        codeTxt.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        phoneTxt.resignFirstResponder()
        codeTxt.resignFirstResponder()
    }
}
