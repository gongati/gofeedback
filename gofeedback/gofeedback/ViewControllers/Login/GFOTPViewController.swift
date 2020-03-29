//
//  GFOTPViewController.swift
//  Genfare
//
//  Created by omniwzse on 05/10/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import FirebaseAuth

class GFOTPViewController: GFBaseViewController {

    @IBOutlet var imgUser: UIImageView!
    @IBOutlet weak var otpText: UITextField!
    
    var userID: String?
    var loginId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func submitOtp(_ sender: Any) {
        
        self.verifyOpt()
    }
    
    func verifyOpt() {
        
        guard let userId = self.userID else {
            
            self.popupAlert(title: "Error", message: "User ID not found", actionTitles: ["OK"], actions: [nil])
            return
        }
        
        if let codeValue = self.otpText.text, codeValue.count >= 6 {
            
            let credential =  PhoneAuthProvider.provider().credential(withVerificationID: userId, verificationCode: codeValue)
             
             Auth.auth().signIn(with: credential) { [weak self] (res, err) in
                 
                 if err != nil{
                     
                    self?.popupAlert(title: "Error", message: err?.localizedDescription, actionTitles: ["OK"], actions: [nil])
                     return
                 }
                
                UserDefaults.standard.set(self?.loginId, forKey: "UserId")
                UserDefaults.standard.set(true, forKey: "loginStatus")
                UserDefaults.standard.synchronize()
                
                self?.dismiss(animated: true, completion: nil)
             }
        } else {
            
            self.popupAlert(title: "Error", message: "Code can not be empty", actionTitles: ["OK"], actions: [nil])
        }
    }
}
