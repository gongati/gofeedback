//
//  ContactViewControllerViewController.swift
//  gofeedback
//
//  Created by OMNIADMIN on 31/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit

class ContactViewControllerViewController: GFBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        
        moveToHomeVC()
    }
    
    func moveToHomeVC() {
        
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "GFNAVIGATEMENUHOME") as? HomeViewController else {
            return
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
