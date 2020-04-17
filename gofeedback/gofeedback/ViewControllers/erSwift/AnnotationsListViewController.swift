//
//  AnnotationsListViewController.swift
//  gofeedback
//
//  Created by OMNIADMIN on 04/04/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import MapKit
import CDYelpFusionKit
import UBottomSheet

class AnnotationsListViewController: BottomSheetController {

    @IBOutlet weak var tableView: UITableView!
    
    var searchItem = "Food"
    
    var dataSource : [CDYelpBusiness]?
    
//    override var bottomYPercentage: CGFloat {
//
//        return 30.0
//    }
//
    override var bottomInset: CGFloat {
        
        return 20.0
    }
        
    override var topInset: CGFloat {
        
        return 100.0
    }

    override var initialPosition: SheetPosition {
        
        return .bottom
    }
    
//    required init?(coder aDecoder: NSCoder) {
//
//        super.init(coder: aDecoder)
//    }
//
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.view.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        self.roundCorners(corners: [.topLeft, .topRight], radius: 12)

        self.tableView.backgroundColor = .clear
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        tableView.register(GFHistoryTableViewCell.self, forCellReuseIdentifier: "DefaultCell")
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
     
        navigationController?.popViewController(animated: true)
    }
    
    @objc func makeCall(number: String) {
        
        
    }
    
    func wayToFeedback(_ value:Int) {
        
        guard let viewController = UIStoryboard(name: "Feedback", bundle: nil).instantiateViewController(withIdentifier:  "FeedbackViewController") as? FeedbackViewController else {
            return
        }
        
        viewController.feedbackModel.restaurantTitle =  dataSource?[value].name ?? ""
        if let location = dataSource?[value].location {
        viewController.feedbackModel.address = "\(location.addressOne ?? "") \(location.addressTwo ?? "") \(location.addressThree ?? "") \(location.city ?? "") \(location.state ?? "") \(location.country ?? "") \(location.zipCode ?? "")"
        }
        viewController.searchItem = self.searchItem
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension AnnotationsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath) as! GFHistoryTableViewCell
        if let business = self.dataSource?[indexPath.row] {
            
            cell.configureCell(business)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.wayToFeedback(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120
    }
}


extension AnnotationsListViewController {
    
        //MARK: BottomSheetController configurations
    //    override var topYPercentage: CGFloat
        
    //    override var bottomYPercentage: CGFloat
        
    //    override var middleYPercentage: CGFloat
        
    //    override var bottomInset: CGFloat
        
    //    override var topInset: CGFloat
        
    //    Don't override if not necessary as it is auto-detected
    //    override var scrollView: UIScrollView?{
    //        return put_your_tableView, collectionView, etc.
    //    }
        
    //    //Override this to apply custom animations
    //    override func animate(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
    //        UIView.animate(withDuration: 0.3, animations: animations)
    //    }
        
    //    To change sheet position manually
    //    call ´changePosition(to: .top)´ anywhere in the code

}
