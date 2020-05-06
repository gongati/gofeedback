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
    
    let CurrentLocationString:String = "Current Location"

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var keywordText: UISearchBar!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var locationBtn: UIButton!
    
    var searchResponse: [CDYelpBusiness]?
    var latitude:Double?
    var longitude:Double?
        
    var isCurrentLocation:Bool = true
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        keywordText.delegate = self
        locationText.delegate = self
        
        self.title = "Search"
        tableView.register(GFHistoryTableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        
        self.keywordText.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.showNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func currentLocationAction(_ sender: Any) {
        
        self.isCurrentLocation = true
        self.locationText.text = self.CurrentLocationString
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if self.isCurrentLocation {
            self.yelpSearch(keywordText.text,locationText.text,self.latitude,self.longitude)
        } else {
            self.yelpSearch(keywordText.text,locationText.text,nil,nil)
            
        }
        searchBar.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text == self.CurrentLocationString || textField.text == "" {
            textField.text = self.CurrentLocationString
            self.yelpSearch(keywordText.text,textField.text,self.latitude,self.longitude)
        } else {
            
            self.yelpSearch(keywordText.text,textField.text,nil,nil)
        }
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        textField.text = nil
        self.locationBtn.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text?.count == 0 {
            
            textField.text = self.CurrentLocationString
        } else {
            
            self.locationBtn.isHidden = true
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
            } else {
                
                self.popupAlert(title: "Alert", message: "Something went wrong, pleae try again.", actionTitles: ["OK"], actions: [nil])
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath) as! GFHistoryTableViewCell
        if let business = self.searchResponse?[indexPath.row] {
            
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
