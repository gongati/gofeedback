//
//  StoreViewController.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 25/04/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit

class StoreViewController: GFBaseViewController {
    
    private let viewModel: StoreViewModel

    
    init(viewModel: StoreViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
    }

}
