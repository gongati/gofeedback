//
//  SideMenuItemsViewController.swift
//  Genfare
//
//  Created by omniwzse on 21/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import FirebaseAuth

class SideMenuItemsViewController: UIViewController {

    @IBOutlet weak var menuPlanTrip: UIButton!
    @IBOutlet weak var menuPassPurchase: UIButton!
    @IBOutlet weak var menuSettings: UIButton!
    @IBOutlet weak var menuLogin: UIButton!
    @IBOutlet weak var menuAlerts: UIButton!
    @IBOutlet weak var menuContactus: UIButton!
    
    @IBOutlet weak var feedListButton: UIButton!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    
    var currentAction:String?
    static var rightNavController:UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.feedListButton.isHidden = true
        updateSideMenu()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //PRAGMA MARK - IBActions
    @IBAction func planTrip(_ sender: UIButton) {
        currentAction = Constants.SideMenuAction.PlanTrip
        dismiss(animated: false) {
            self.navigateToPlanTrip()
        }
    }
    
    @IBAction func showPasses(_ sender: UIButton) {
        currentAction = Constants.SideMenuAction.PassPurchase
        dismiss(animated: false){
            self.navigateToPasses()
        }
    }

    @IBAction func showAlerts(_ sender: UIButton) {
        currentAction = Constants.SideMenuAction.Alerts
        dismiss(animated: false){
            self.navigateToAlerts()
        }
    }
    
    @IBAction func showSettings(_ sender: UIButton) {
        currentAction = Constants.SideMenuAction.Settings

        dismiss(animated: false) {
            self.navigateToSettings()
        }
    }
    
    @IBAction func showContactus(_ sender: UIButton) {
        currentAction = Constants.SideMenuAction.ContactUs
        dismiss(animated: false) {
            self.navigateToContactus()
        }
    }
    
    @IBAction func userLogin(_ sender: UIButton) {
        currentAction = Constants.SideMenuAction.Login

        dismiss(animated: false) {
            self.navigateToLogin()
        }
    }

    @objc func navigateToPlanTrip() {
        print("SIDEMENU - Plan Trip")
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.PlanTrip {
            SideMenuItemsViewController.rightNavController?.popToRootViewController(animated: false)
            return
        }
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GFNAVIGATEMENUHOME") as? HomeViewController {
            attachControllerToMainWindow(controller: controller)
        }
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.PlanTrip
    }

    @objc func navigateToPasses() {
        print("SIDEMENU - My Passes")
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.PassPurchase {
            SideMenuItemsViewController.rightNavController?.popToRootViewController(animated: false)
            return
        }
        
        if shouldShowLogin() {
            navigateToLogin()
            return
        }
        
        showAccountHome()
    }
    
    @objc func navigateToLogin() {
        print("SIDEMENU - Login")
        if shouldShowLogin() {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Constants.NotificationKey.Login)))
            return
        }
        showLogoutAlert()
    }
    
    @objc func navigateToAlerts() -> Void {
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.Alerts {
            SideMenuItemsViewController.rightNavController?.popToRootViewController(animated: false)
            return
        }
        
        //TODO - Alerts need to be integrated
        popupAlert(title: "Alert", message: "Alerts are not ready yet", actionTitles: ["OK"], actions: [nil])
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.Alerts
    }
    
    @objc func navigateToSettings() -> Void {
        print("SIDEMENU - Settings")
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.Settings {
            SideMenuItemsViewController.rightNavController?.popToRootViewController(animated: false)
            return
        }

        if shouldShowLogin() {
            navigateToLogin()
            return
        }

        if let controller = UIStoryboard(name: "Account", bundle: nil).instantiateInitialViewController(){
            
            attachControllerToMainWindow(controller: controller)
        }
        
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.Settings
    }
    
    @objc func navigateToContactus() -> Void {
        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.ContactUs {
            SideMenuItemsViewController.rightNavController?.popToRootViewController(animated: false)
            return
        }
        showContactPage()
        //TODO - Alerts need to be integrated
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.ContactUs
    }
        func showContactPage() {
            if let controller = UIStoryboard(name: "Contact", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.Contact) as? ContactViewControllerViewController {
                attachControllerToMainWindow(controller: controller)
        }
    }
    
    func updateSideMenu() {
        
        if self.shouldShowLogin() {
            
            showLoginButton(status: true)
        }else{
            
            showLoginButton(status: false)
        }
        
//        userNameLabel.text = userAccount?.firstName
//        emailLabel.text = userAccount?.emailaddress
    }

    func showAccountHome() {
        //TODO - Passes need to be integrated
        if let controller = UIStoryboard(name: "Wallet", bundle: nil).instantiateInitialViewController() {
            attachControllerToMainWindow(controller: controller)
            GFBaseViewController.currentMenuItem = Constants.SideMenuAction.PassPurchase
        }
    }

    func shouldShowLogin() -> Bool {
        
        guard let loginStatus = UserDefaults.standard.value(forKey: "loginStatus") as? Bool else
        {
            return true
        }
        
        return !loginStatus
    }
    
    func showLoginButton(status:Bool) {
        if status {
            menuLogin.setTitle("Log In", for: .normal)
            menuLogin.setImage(UIImage(named: "sign-in-alt-light"), for: .normal)
        }else {
            menuLogin.setTitle("Log Out", for: .normal)
            menuLogin.setImage(UIImage(named: "sign-out-alt-light"), for: .normal)
            if let name = UserDefaults.standard.string(forKey: "UserName"), let email = UserDefaults.standard.string(forKey: "Email") {
            
                self.userNameLabel.text = name
                self.emailLabel.text = email
            }
        }
    }

    func popupAlert(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        let app = UIApplication.shared
        app.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    @objc func confirmLogout() -> Void {
        
        UserDefaults.standard.set(false, forKey: "loginStatus")
        UserDefaults.standard.removeObject(forKey: "UserId")
        UserDefaults.standard.set("",forKey: "UserName")
        UserDefaults.standard.set("",forKey: "email")
        UserDefaults.standard.synchronize()

        if GFBaseViewController.currentMenuItem == Constants.SideMenuAction.PlanTrip {
            SideMenuItemsViewController.rightNavController?.popToRootViewController(animated: false)
            return
        }
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GFNAVIGATEMENUHOME") as? HomeViewController {
            attachControllerToMainWindow(controller: controller)
        }
        GFBaseViewController.currentMenuItem = Constants.SideMenuAction.PlanTrip
    }

    func showLogoutAlert() -> Void {
        // create the alert
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to logout?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: UIAlertAction.Style.destructive, handler: { action in
            
            
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                self.confirmLogout()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
                _ = UIAlertController(title: "Logout Status", message: "Failed to signing out, try again after sometime.", preferredStyle: UIAlertController.Style.alert)
            }
            
        }))
        
        let windows = UIApplication.shared.windows
        let mainWindow = windows.first
        
        // show the alert
        topViewController(mainWindow?.rootViewController)!.present(alert, animated: true, completion: nil)
        //present(alert, animated: true, completion: nil)
    }

    @objc override func attachControllerToMainWindow(controller:UIViewController) {
        
        SideMenuItemsViewController.rightNavController?.viewControllers = [controller]
    }
}

extension UIViewController {
    
    @objc func attachControllerToMainWindow(controller:UIViewController) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let navController = UINavigationController(rootViewController: controller)
        appDelegate.window?.rootViewController = navController
        appDelegate.window!.makeKeyAndVisible()
    }
    
    func topViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        if rootViewController?.presentedViewController == nil {
            return rootViewController
        }
        
        if type(of: rootViewController?.presentedViewController) == UINavigationController.self {
            let navigationController = rootViewController?.presentedViewController as? UINavigationController
            let lastViewController: UIViewController? = navigationController?.viewControllers.last
            return topViewController(lastViewController)
        }
        
        let presentedViewController = rootViewController?.presentedViewController as? UIViewController
        return topViewController(presentedViewController)
    }
}

