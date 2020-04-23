//
//  AccountSettingsViewController.swift
//  gofeedback
//
//  Created by OMNIADMIN on 29/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit

class AccountSettingsViewController: GFBaseViewController {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var MobileNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userData()
        self.attachSpinner(value: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.view.backgroundColor = UIColor.white
    }
    
    
    @IBAction func backPressed(_ sender: UIButton) {
        
        self.moveToHomeVC()
    }
    
    func userData() {
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            
            GFFirebaseManager.getUserdetails(userName: userId) { (userModel) in
                
                if let userModel = userModel {
                    
                    self.UIUpdate(userModel)
                    self.attachSpinner(value: false)
                } else {
                    
                    self.popupAlert(title: "Alert", message: "Document does not exist", actionTitles: ["OK"], actions: [{ action in
                        
                        self.moveToHomeVC()
                        }])
                }
            }
        }
    }
    
    func moveToHomeVC() {
        
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "GFNAVIGATEMENUHOME") as? HomeViewController else {
            return
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func UIUpdate(_ data:UserModel) {
        
        self.firstNameLabel.text = data.firstName
        self.lastNameLabel.text = data.lastName
        self.MobileNumberLabel.text = data.mobileNumber
        self.emailLabel.text = data.email
        self.addressLabel.text = data.address
    }
    
}
