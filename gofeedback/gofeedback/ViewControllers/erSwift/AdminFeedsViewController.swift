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
    var state:FeedbackStatus = .Submitted
    var isStackViewHidden = false
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var stackVIew: UIStackView!
    @IBOutlet weak var pendingBtnOutlet: UIButton!
    @IBOutlet weak var approvedBtnOutlet: UIButton!
    @IBOutlet weak var rejectedBtnOutlet: UIButton!
    @IBOutlet weak var paidBtnPressed: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
        if isStackViewHidden {
            
            self.stackVIew.isHidden = true
            self.tableView.snp.makeConstraints { (make) in
                
                make.edges.equalToSuperview()
            }
        } else {
            
            approvedBtnOutlet.backgroundColor = UIColor.gray
            rejectedBtnOutlet.backgroundColor = UIColor.gray
            paidBtnPressed.backgroundColor = UIColor.gray
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.showNavBar()

        self.attachSpinner(value: true)
        getFeedsDetails()
    }
    
    @IBAction func pendingBtnPressed(_ sender: UIButton) {
        
        pendingBtnOutlet.backgroundColor = UIColor(red: 40/255, green: 153/255, blue: 212/255, alpha: 1)
        approvedBtnOutlet.backgroundColor = UIColor.gray
        rejectedBtnOutlet.backgroundColor = UIColor.gray
        paidBtnPressed.backgroundColor = UIColor.gray
        
        self.attachSpinner(value: true)
        self.state = .Submitted
        self.getFeedsDetails()
    }
    
    @IBAction func approvedBtnPressed(_ sender: UIButton) {
        
        approvedBtnOutlet.backgroundColor = UIColor(red: 40/255, green: 153/255, blue: 212/255, alpha: 1)
        pendingBtnOutlet.backgroundColor = UIColor.gray
        rejectedBtnOutlet.backgroundColor = UIColor.gray
        paidBtnPressed.backgroundColor = UIColor.gray
        
        self.attachSpinner(value: true)
        self.state = .Approved
        self.getFeedsDetails()
    }
    
    @IBAction func rejectedBtnPressed(_ sender: UIButton) {
        
        rejectedBtnOutlet.backgroundColor = UIColor(red: 40/255, green: 153/255, blue: 212/255, alpha: 1)
        approvedBtnOutlet.backgroundColor = UIColor.gray
        pendingBtnOutlet.backgroundColor = UIColor.gray
        paidBtnPressed.backgroundColor = UIColor.gray
        
        self.attachSpinner(value: true)
        self.state = .Rejected
        self.getFeedsDetails()
    }
    
    @IBAction func paidBtnPressed(_ sender: UIButton) {
        
        paidBtnPressed.backgroundColor = UIColor(red: 40/255, green: 153/255, blue: 212/255, alpha: 1)
        approvedBtnOutlet.backgroundColor = UIColor.gray
        rejectedBtnOutlet.backgroundColor = UIColor.gray
        pendingBtnOutlet.backgroundColor = UIColor.gray
        
        self.attachSpinner(value: true)
        self.state = .Paid
        self.getFeedsDetails()
    }
    
    func getFeedsDetails() {
        
        GFFirebaseManager.loadAllFeeds { (feeds) in
            
            if let feeds = feeds {
                
                let sortedFeeds = feeds.filter { $0.status.rawValue == self.state.rawValue}
                
                self.feedbackModels = sortedFeeds
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
        if (feedbackModel.status.rawValue != FeedbackStatus.Approved.rawValue)  && feedbackModel.status.rawValue != FeedbackStatus.Paid.rawValue {
            
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
