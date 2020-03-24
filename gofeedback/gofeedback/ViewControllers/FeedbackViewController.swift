//
//  ViewController.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 04/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

    @IBOutlet weak var restuarantName: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var restaurantTitle = ""
    var address = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        restuarantName.text = restaurantTitle
        addressLabel.text = address
    }

    @IBAction func cancelPressed(_ sender: UIButton) {
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    
}

