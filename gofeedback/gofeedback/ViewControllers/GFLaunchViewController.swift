//
//  GFLaunchViewController.swift
//  Genfare
//
//  Created by vishnu on 09/01/19.
//  Copyright © 2019 Genfare. All rights reserved.
//

import UIKit
import CoreData

class GFLaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.gotoHomeScreen()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func gotoHomeScreen() {
        let mainStory = UIStoryboard(name: "Main", bundle: nil)
        let vc:HomeViewController = mainStory.instantiateViewController(withIdentifier: "GFNAVIGATEMENUHOME") as! HomeViewController
        let navController = UINavigationController(rootViewController: vc)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navController
    }
}
