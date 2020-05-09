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
    var allFeeds = [[String:[FeedbackModel]]]()
    var selectedItems = [FeedbackModel]()
    var isOwnedItems = false
    var images = [UIImage]()
    var videoUrl = [URL]()
    var videotag = [Int]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buyButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        if self.isOwnedItems {
            
            self.showOwnedFeeds()
            self.title = "My Feedbacks"
        }else {
            
            self.showAcceptedFeeds()
            self.title = "All Feedbacks"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.showNavBar()
        self.navigationController?.navigationBar.backItem?.title = ""
    }
    
    @IBAction func myListBtnPressed(_ sender: UIButton) {
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return isOwnedItems == true ? 1 : allFeeds.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return isOwnedItems == true ? dataSource.count : allFeeds[section].values.first?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return isOwnedItems == true ? nil : allFeeds[section].keys.first
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as? EnterpriseListViewCell {
        if isOwnedItems {
            cell.accessoryType = .disclosureIndicator
            cell.updateCell(isOwnedItems, dataSource[indexPath.row])
        } else {
            cell.accessoryType = .none
            if let feeds = allFeeds[indexPath.section].values.first?[indexPath.row] {
            cell.updateCell(isOwnedItems, feeds)
            }
        }
        return cell
        }
        return UITableViewCell()
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
            if let feed = allFeeds[indexPath.section].values.first?[indexPath.row] {
                
            self.selectedItems.append(feed)
            }
            if selectedItems.count > 0 {
                
                self.buyButton.isHidden = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let newCell = tableView.cellForRow(at: indexPath)
        newCell?.accessoryType = .none
        if let feed = allFeeds[indexPath.section].values.first?[indexPath.row] {
            let value = self.selectedItems.filter {
                $0.feedbackId != feed.feedbackId
            }
            self.selectedItems = value
        }
        if selectedItems.count == 0 {
            
            self.buyButton.isHidden = true
        }
    }
    
    func showAcceptedFeeds() {
        
        self.attachSpinner(value: true)
        self.tableView.allowsMultipleSelection = true
        allFeeds.removeAll()
        buyButton.isHidden = true
        isOwnedItems = false
        viewModel.loadAcceptedItems {
            if let acceptedItems = self.viewModel.acceptedItems {
                
                loop1:for i in 0..<acceptedItems.count {
                    
                    for j in 0..<self.allFeeds.count {
                        
                        if self.allFeeds[j].keys.first == acceptedItems[i].restaurantTitle {
                            
                            if var feeds = self.allFeeds[j].values.first {
                                
                                feeds.append(acceptedItems[i])
                                self.allFeeds[j] = [acceptedItems[i].restaurantTitle:feeds]
                                continue loop1
                            }
                        }
                    }
                    self.allFeeds.append([acceptedItems[i].restaurantTitle:[acceptedItems[i]]])
                }
                self.tableView.reloadData()
            }
            self.attachSpinner(value: false)
        }
    }
    
    func showOwnedFeeds() {
        
        self.attachSpinner(value: true)
        self.tableView.allowsMultipleSelection = false
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
