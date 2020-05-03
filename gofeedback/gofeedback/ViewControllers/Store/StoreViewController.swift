//
//  StoreViewController.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 25/04/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit

class StoreViewController: GFBaseViewController,UITableViewDelegate,UITableViewDataSource {
    
   private let viewModel = StoreViewModel()
    
    var dataSource = [FeedbackModel]()
    var selectedItems = [FeedbackModel]()
    var isOwnedItems = false
    var images = [UIImage]()
    var videoUrl = [URL]()
    var videotag = [Int]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var myListBtnOutlet: UIButton!
    @IBOutlet weak var storeBtnOutlet: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        showAcceptedFeeds()
    }
    
    @IBAction func storeBtnPressed(_ sender: UIButton) {
        
        storeBtnOutlet.backgroundColor = UIColor(red: 40/255, green: 153/255, blue: 212/255, alpha: 1)
        showAcceptedFeeds()
    }
    
    @IBAction func myListBtnPressed(_ sender: UIButton) {
        
        myListBtnOutlet.backgroundColor = UIColor(red: 40/255, green: 153/255, blue: 212/255, alpha: 1)
        storeBtnOutlet.backgroundColor = UIColor.brown
        self.tableView.allowsMultipleSelection = false
        self.attachSpinner(value: true)
        dataSource.removeAll()
        selectedItems.removeAll()
        buyButton.isHidden = true
        isOwnedItems = true
        viewModel.loadOwnedItems {
            if let ownedItems = self.viewModel.ownedItems {
            self.dataSource = ownedItems
            self.tableView.reloadData()
            }
            self.attachSpinner(value: false)
        }
    }
    
    @IBAction func buyBtnPressed(_ sender: UIButton) {
        
        self.attachSpinner(value: true)
        dataSource.removeAll()
        buyButton.isHidden = true
        viewModel.buyItems(selectedItems) { (value) in
            
            var msg = ""
            if value {
                
                msg = "Successfully buyed \(self.selectedItems.count) selected Feeds"
            } else {
                
                msg = "Failed to buy \(self.selectedItems.count) selected Feeds"
            }
             self.selectedItems.removeAll()
            self.attachSpinner(value: false)
            self.popupAlert(title: "Alert", message: msg, actionTitles: ["OK"], actions: [{ action in
    
                self.showAcceptedFeeds()
             }])
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        if isOwnedItems {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = self.dataSource[indexPath.row].restaurantTitle
        cell.detailTextLabel?.text = self.dataSource[indexPath.row].address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isOwnedItems {
            images.removeAll()
            videoUrl.removeAll()
            videotag.removeAll()
            self.moveToPreviewVC(indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            let newCell = tableView.cellForRow(at: indexPath)
            newCell?.accessoryType = .checkmark
            self.selectedItems.append(self.dataSource[indexPath.row])
            if selectedItems.count > 0 {
                
                self.buyButton.isHidden = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let newCell = tableView.cellForRow(at: indexPath)
        newCell?.accessoryType = .none
        let value = self.selectedItems.filter {
            $0.feedbackId != self.dataSource[indexPath.row].feedbackId
        }
        self.selectedItems = value
        if selectedItems.count == 0 {
            
            self.buyButton.isHidden = true
        }
    }
    
    func showAcceptedFeeds() {
        
        self.myListBtnOutlet.backgroundColor = UIColor.brown
        self.attachSpinner(value: true)
        self.tableView.allowsMultipleSelection = true
        dataSource.removeAll()
        buyButton.isHidden = true
        isOwnedItems = false
        viewModel.loadAcceptedItems {
            if let acceptedItems = self.viewModel.acceptedItems {
                self.dataSource = acceptedItems
                self.tableView.reloadData()
            }
            self.attachSpinner(value: false)
        }
    }
    
    func moveToPreviewVC(_ at:Int) {
        
        guard let viewController = UIStoryboard(name: "Feedback", bundle: nil).instantiateViewController(withIdentifier:  "PreviewFeedbackViewController") as? PreviewFeedbackViewController else {
            return
        }
        
        viewController.feedbackModel = self.dataSource[at]
        
        if self.dataSource[at].status  == FeedbackStatus.Drafts {
            
            viewController.isSubmitBtnHidden = false
            viewController.feedbackModel.status = .Drafts
            
        } else {
            
            viewController.isSubmitBtnHidden = true
        }
        let group = DispatchGroup()
        
        if let videoFiles = self.dataSource[at].videoFilName {
            for path in videoFiles {
                group.enter()
                GFFirebaseManager.downloadVideoUrl(path) { (url) in
                    
                    if let url = url {
                        
                        self.videoUrl.append(url)
                        print("sucess Form")
                        print(viewController.videoUrl!)
                    } else {
                        
                        print("error")
                    }
                    group.leave()
                }
            }
        } else {
            group.enter()
            group.leave()
        }
        
        group.notify(queue: .main) {
            
            let group2 = DispatchGroup()
            
            if let imagefiles = self.dataSource[at].imageFileName {
                for path in imagefiles {
                    
                    group2.enter()
                    GFFirebaseManager.downloadImage(path) { (image) in
                        
                        if let image = image {
                            self.images.append(image)
                            print(self.images)
                            print(image)
                            print("sucess Image")
                            
                            if let videoFiles = self.dataSource[at].videoFilName {
                                for tag in videoFiles {
                                    
                                    let new = tag.replacingOccurrences(of: "Videos/", with: "Images/", options: .regularExpression, range: nil)
                                    let new2 = new.replacingOccurrences(of: ".mp4", with: ".jpg", options: .regularExpression, range: nil)
                                    if path == new2 {
                                        
                                        self.videotag.append(self.images.count - 1)
                                    }
                                }
                            }
                        } else {
                            
                            print("error")
                        }
                        group2.leave()
                    }
                }
            } else {
                
                group2.enter()
                group2.leave()
            }
            group2.notify(queue: .main) {
                
                viewController.images = self.images
                viewController.videoUrl = self.videoUrl
                viewController.videoTag = self.videotag
                print(viewController.images!)
                print("navigation")
                self.attachSpinner(value: false)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}
