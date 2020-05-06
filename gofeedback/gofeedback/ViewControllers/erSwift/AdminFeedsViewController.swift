//
//  AdminFeedsViewController.swift
//  gofeedback
//
//  Created by OMNIADMIN on 19/04/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit

class AdminFeedsViewController: GFBaseViewController,UITableViewDataSource,UITableViewDelegate {
    
    var images = [UIImage]()
    var videoUrl = [URL]()
    var videotag = [Int]()
    var feedbackModels : [FeedbackModel]?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.showNavBar()

        self.attachSpinner(value: true)
        getFeedsDetails()
    }
    
    func getFeedsDetails() {
        
        GFFirebaseManager.loadAllFeeds { (feeds) in
            
            if let feeds = feeds {
                
                self.feedbackModels = feeds
                self.tableView.reloadData()
                self.attachSpinner(value: false)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.feedbackModels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdminFeedsCell", for: indexPath) as! GFAdminFeedListViewCell
        
        if let feedItem = self.feedbackModels?[indexPath.row] {
            
            cell.updateCell(model: feedItem)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.attachSpinner(value: true)
        images.removeAll()
        videoUrl.removeAll()
        videotag.removeAll()
        moveToPreviewVC(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func moveToPreviewVC(_ at:Int) {
        
        guard let viewController = UIStoryboard(name: "Feedback", bundle: nil).instantiateViewController(withIdentifier:  "PreviewFeedbackViewController") as? PreviewFeedbackViewController else {
            return
        }
        
        if let feedbackModel = self.feedbackModels?[at] {
        viewController.feedbackModel = feedbackModel
        
        viewController.isSubmitBtnHidden = true
        if (feedbackModel.status.rawValue != FeedbackStatus.Rejected.rawValue)  && feedbackModel.status.rawValue != FeedbackStatus.Paid.rawValue {
            
            viewController.isApprovedBtnHidden = false
            viewController.isRejectbtnHidden = false
        }
        let group = DispatchGroup()
        
        if let imagefiles = self.feedbackModels?[at].imageFileName {
            for path in imagefiles {
                
                group.enter()
                GFFirebaseManager.downloadImage(path) { (image) in
                    
                    if let image = image {
                        self.images.append(image)
                        print(self.images)
                        print(image)
                        print("sucess Image")
                        
                        if let videoFiles = feedbackModel.videoFilName {
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
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            
            let group2 = DispatchGroup()
            
            if let videoFiles = self.feedbackModels?[at].videoFilName {
                for path in videoFiles {
                    group2.enter()
                    GFFirebaseManager.downloadVideoUrl(path) { (url) in
                        
                        if let url = url {
                            
                            self.videoUrl.append(url)
                            print("sucess Form")
                            print(viewController.videoUrl!)
                        } else {
                            
                            print("error")
                        }
                        group2.leave()
                    }
                }
            }
            
            group2.notify(queue: .main) {
                
                viewController.images = self.images
                viewController.videoUrl = self.videoUrl
                viewController.videoTag = self.videotag
                viewController.adminFeedId = self.feedbackModels?[at].feedbackId
                print(viewController.images!)
                print("navigation")
                self.attachSpinner(value: false)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}
}
