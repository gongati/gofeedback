//
//  GFRouteLegsScrollView.swift
//  Genfare
//
//  Created by omniwzse on 12/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFRouteLegsScrollView: UIScrollView {

    let startX:CGFloat = 4
    let walkWidth:CGFloat = 20
    let walkHeight:CGFloat = 20
    let walkY:CGFloat = 12
    let busWidth:CGFloat = 20
    let busHeight:CGFloat = 20
    let busY:CGFloat = 12
    let labelFlowX:CGFloat = 10
    let labelFlowY:CGFloat = 11
    let labelWidth:CGFloat = 10
    
    let itemDistance:CGFloat = 15
    
    var currentX:CGFloat = 0

    func reset(){
        currentX = startX
        for view in subviews {
            view.removeFromSuperview()
        }
    }

    private func styleLabel(label:UILabel) {
          label.layer.cornerRadius = label.frame.size.height/2
          label.layer.backgroundColor = UIColor.buttonBGBlue.cgColor
      }
}
