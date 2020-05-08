//
//  AdminHomeViewController.swift
//  gofeedbackadmin
//
//  Created by Vishnu Vardhan Reddy G on 04/05/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import Firebase

class AdminHomeViewController: GFBaseViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var totalFeeds: UILabel!
    
    @IBOutlet weak var myFeeds: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var myFeedsView: GFCustomTableViewCellShadowView!
    @IBOutlet weak var storeFeedsView: GFCustomTableViewCellShadowView!
    @IBOutlet weak var adminFeedsView: GFCustomTableViewCellShadowView!
    
    @IBOutlet weak var seeAllBtn1: UIButton!
    
    
    @IBOutlet weak var view1: GFCustomTableViewCellShadowView!
    
    @IBOutlet weak var view2: GFCustomTableViewCellShadowView!
    
    @IBOutlet weak var view3: GFCustomTableViewCellShadowView!
    
    @IBOutlet weak var view4: GFCustomTableViewCellShadowView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "GoFeedback"
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isUserLoggedIn {
            
            self.showUserLogin()
        }else if let userType =  UserDefaults.standard.string(forKey: "UserType") {

            if userType == "1" {
                
                self.setupSuperAdmin()
            } else if userType == "2" {

                self.setupEnterPrise()
            } else {
                
                self.setupNormalUser()
            }
        }
        self.showNavBar()
        self.updateNavBar()
    }

    func updateNavBar() {
        
        let logoutButton:UIBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(showLogoutAlert))
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    @IBAction func adminFeedsTapped(_ sender: UIButton) {
        
        self.showAdminFeeds()
    }
    
    @IBAction func storeFeedsTapped(_ sender: UIButton) {
        
        self.showTotalFeeds()
    }
    
    @IBAction func myFeedsTapped(_ sender: Any) {
     
        self.showOwnedFeeds()
    }
    
    func setupSuperAdmin() {
        
        self.hideAllViews()
        self.adminFeedsView.isHidden = false
        self.userNameLabel.text = "Administrator"
        
        self.view1.isHidden = false
        self.view2.isHidden = false
        self.view3.isHidden = false
        self.view4.isHidden = false
    }
    
    func setupEnterPrise() {
        
        self.hideAllViews()
        self.storeFeedsView.isHidden = false
        self.myFeedsView.isHidden = false
        self.userNameLabel.text = "Enterprise"
    }
    
    func setupNormalUser() {
        
        
    }
    
    func hideAllViews() {
        
        self.storeFeedsView.isHidden = true
        self.myFeedsView.isHidden = true
        self.adminFeedsView.isHidden = true
        
        self.view1.isHidden = true
        self.view2.isHidden = true
        self.view3.isHidden = true
        self.view4.isHidden = true
    }
    
    func showTotalFeeds() {
        
        if let controller = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.EnterpriseFeeds) as? StoreViewController {
            controller.isOwnedItems = false
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    func showOwnedFeeds() {
        
        if let controller = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.EnterpriseFeeds) as? StoreViewController {
            controller.isOwnedItems = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func showAdminFeeds() {
        
        if let controller = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.AdminFeeds) as? AdminFeedsViewController {
                self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension AdminHomeViewController {
    
    @objc func confirmLogout() -> Void {
        
        GFUserDefaults.removingUserDefaults()
        self.showUserLogin()
    }

    @objc func showLogoutAlert() -> Void {
        // create the alert
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to logout?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: UIAlertAction.Style.destructive, handler: { [weak self] action in
            
            
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                self?.confirmLogout()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
                _ = UIAlertController(title: "Logout Status", message: "Failed to signing out, try again after sometime.", preferredStyle: UIAlertController.Style.alert)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
