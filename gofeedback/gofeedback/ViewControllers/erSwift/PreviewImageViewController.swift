//
//  PreviewImageViewController.swift
//  gofeedback
//
//  Created by OMNIADMIN on 04/04/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit

class PreviewImageViewController: UIViewController {

    var image : UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.imageView.image = image
    }

    @IBAction func backPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
}
