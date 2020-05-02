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

class AnnotationsListViewController: UIViewController, Draggable {

    @IBOutlet weak var tableView: UITableView!
    
    var searchItem = "Food"
    
    var dataSource : [CDYelpBusiness]?
    
    var sheetCoordinator: UBottomSheetCoordinator?

    func draggableView() -> UIScrollView? {
        return tableView
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
        
        sheetCoordinator?.startTracking(item: self)
        
        tableView.tableFooterView = UIView()
        tableView.register(GFHistoryTableViewCell.self, forCellReuseIdentifier: "DefaultCell")
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
     
        navigationController?.popViewController(animated: true)
    }
    
    @objc func makeCall(number: String) {
        
        
    }
    
    func distanceSorting() {
        
        if self.dataSource != nil {
            
            for i in 0..<(self.dataSource?.count  ?? 0){
                for j in 0..<(self.dataSource?.count  ?? 0){
                    
                    if self.dataSource?[i].distance ?? 0 < self.dataSource?[j].distance ?? 0 {
                        
                        let temp = self.dataSource?[i]
                        let temp2 = self.dataSource?[j]
                        self.dataSource?[i] = (temp2)!
                        self.dataSource?[j] = temp!
                    }
                }
            }
        }
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
        viewController.bussiness = dataSource?[value]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension AnnotationsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.distanceSorting()
        
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



