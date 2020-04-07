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

class AnnotationsListViewController: GFBaseViewController, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var searchItem = "Food"
    var dataSource : [CDYelpBusiness]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.view.backgroundColor = .gray
        self.tableView.backgroundColor = .clear
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        tableView.register(GFHistoryTableViewCell.self, forCellReuseIdentifier: "DefaultCell")
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
     
        navigationController?.popViewController(animated: true)
    }
    
    
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
