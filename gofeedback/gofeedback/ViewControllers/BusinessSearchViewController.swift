//
//  BusinessSearchViewController.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 02/05/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import CDYelpFusionKit

class BusinessSearchViewController: GFBaseViewController,UISearchBarDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var keywordText: UISearchBar!
    @IBOutlet weak var locationText: UITextField!
    
    var searchResponse: [CDYelpBusiness]?
    var latitude:Double?
    var longitude:Double?
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        keywordText.delegate = self
        locationText.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if locationText.text == "Current Location" {
            self.yelpSearch(keywordText.text,locationText.text,self.latitude,self.longitude)
        } else {
            self.yelpSearch(keywordText.text,locationText.text,nil,nil)
            
        }
        searchBar.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text == "Current Location" || textField.text == "" {
            textField.text = "Current Location"
            self.yelpSearch(keywordText.text,textField.text,self.latitude,self.longitude)
        } else {
            
            self.yelpSearch(keywordText.text,textField.text,nil,nil)
        }
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        textField.text = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text?.count == 0 {
            
            textField.text = "Current Location"
        }
    }
    
    @objc override func keyboardWillShow(notification: NSNotification) {
        
        if self.view.frame.origin.y == 0 {
            
            self.view.frame.origin.y -= 0
        }
    }
    
    func yelpSearch(_ searchString:String?,_ locationString:String?,_ latitude:Double?,_ longitude:Double?) {
        
        GFYelpManager.yelpSearch(byTerm: searchString, location: locationString, latitude: latitude, longitude: longitude, radius: 25000) { (response) in
            
            if let response = response,
                let businesses = response.businesses {
                
                if businesses.count == 0 {
                    
                    self.searchResponse = nil
                    self.popupAlert(title: "Alert", message: "No matches Found", actionTitles: ["OK"], actions: [nil])
                    
                } else {
                    print(response)
                    
                    self.searchResponse = response.businesses
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func wayToFeedback(_ value:Int) {
        
        guard let viewController = UIStoryboard(name: "Feedback", bundle: nil).instantiateViewController(withIdentifier:  "FeedbackViewController") as? FeedbackViewController else {
            return
        }
        
        viewController.feedbackModel.restaurantTitle =  searchResponse?[value].name ?? ""
        if let location = searchResponse?[value].location {
        viewController.feedbackModel.address = "\(location.addressOne ?? "") \(location.addressTwo ?? "") \(location.addressThree ?? "") \(location.city ?? "") \(location.state ?? "") \(location.country ?? "") \(location.zipCode ?? "")"
        }
        viewController.searchItem = self.keywordText.text ?? ""
        viewController.bussiness = searchResponse?[value]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension BusinessSearchViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.searchResponse?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ANNOTATIONCELL", for: indexPath)
        if let business = searchResponse,let location = business[indexPath.row].location {
            
            cell.textLabel?.text = business[indexPath.row].name
            cell.detailTextLabel?.text = "\(location.addressOne ?? "") \(location.addressTwo ?? "") \(location.addressThree ?? "") \(location.city ?? "") \(location.state ?? "") \(location.country ?? "") \(location.zipCode ?? "")"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.wayToFeedback(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
