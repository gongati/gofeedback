//
//  AccountSettingsViewController.swift
//  gofeedback
//
//  Created by OMNIADMIN on 29/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import Firebase

class AccountSettingsViewController: GFBaseViewController {

    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var MobileNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.userData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.view.backgroundColor = UIColor.white
    }
    
    
    @IBAction func Back(_ sender: UIButton) {
        
        self.moveToHomeVC()
    }
    
    func userData() {
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            let docRef = db.collection("Users").document(userId)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists,
                    let dataDescription = document.data() {
                    print("Document data: \(dataDescription)")
                    
                    self.UIUpdate(dataDescription)
                } else {
                    print("Document does not exist")
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
    
    func UIUpdate(_ data:[String:Any]) {
        
        self.firstNameLabel.text = data[Constants.userDetails.firstName] as? String
        self.lastNameLabel.text = data[Constants.userDetails.lastName] as? String
        self.MobileNumberLabel.text = data[Constants.userDetails.mobileNumber] as? String
        self.emailLabel.text = data[Constants.userDetails.email] as? String
        self.addressLabel.text = data[Constants.userDetails.address] as? String
    }

}
