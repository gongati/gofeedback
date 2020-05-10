//
//  WalletViewController.swift
//  gofeedback
//
//  Created by OMNIADMIN on 29/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit

class WalletViewController: GFBaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var walletBalanceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var paidBtnOutlet: UIButton!
    @IBOutlet weak var submittedBtnOutlet: UIButton!
    @IBOutlet weak var draftsBtnOulet: UIButton!
    
    var images = [UIImage]()
    var videoUrl = [URL]()
    var videotag = [Int]()
    var firstTimeLoad = true
    var feedbackModel = [FeedbackModel]()
    var state:FeedbackStatus = .none
    
    let dg = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        self.draftsLoadFirstTime()
        self.attachSpinner(value: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        if self.state == .Drafts {
            self.attachSpinner(value: true)
            self.feedbackModel.removeAll()
            dg.enter()
            self.getFeedBackDetails(FeedbackStatus.Drafts.rawValue) {
                self.dg.leave()
            }
            dg.notify(queue: .main) {
                self.attachSpinner(value: false)
            }
        } else {
            
        tableView.reloadData()
        }
    }
    
    @IBAction func submiteedPressed(_ sender: UIButton) {
        
        submittedBtnOutlet.backgroundColor = UIColor(red: 40/255, green: 153/255, blue: 212/255, alpha: 1)
        paidBtnOutlet.backgroundColor = UIColor.gray
        draftsBtnOulet.backgroundColor = UIColor.gray
        
        self.attachSpinner(value: true)
        
        self.feedbackModel.removeAll()
        dg.enter()
        self.getFeedBackDetails(FeedbackStatus.Rejected.rawValue) {
            self.dg.leave()
        }
        dg.notify(queue: .main) {
            self.dg.enter()
            self.getFeedBackDetails(FeedbackStatus.Paid.rawValue) {
                self.dg.leave()
            }
            self.dg.notify(queue: .main) {
                self.dg.enter()
                self.getFeedBackDetails(FeedbackStatus.Approved.rawValue) {
                    self.dg.leave()
                }
                self.dg.notify(queue: .main) {
                    self.dg.enter()
                    self.getFeedBackDetails(FeedbackStatus.Submitted.rawValue) {
                        self.dg.leave()
                    }
                    self.dg.notify(queue: .main) {
                        self.attachSpinner(value: false)
                    }
                }
            }
        }
    }
    
    @IBAction func paidPressed(_ sender: UIButton) {
        
        paidBtnOutlet.backgroundColor = UIColor(red: 40/255, green: 153/255, blue: 212/255, alpha: 1)
        draftsBtnOulet.backgroundColor = UIColor.gray
        submittedBtnOutlet.backgroundColor = UIColor.gray
        
        self.attachSpinner(value: true)
        self.feedbackModel.removeAll()
        dg.enter()
        self.getFeedBackDetails(FeedbackStatus.Paid.rawValue) {
            self.dg.leave()
        }
        dg.notify(queue: .main) {
            self.attachSpinner(value: false)
        }
    }
    
    @IBAction func draftsPressed(_ sender: UIButton) {
        
        draftsBtnOulet.backgroundColor = UIColor(red: 40/255, green: 153/255, blue: 212/255, alpha: 1)
        paidBtnOutlet.backgroundColor = UIColor.gray
        submittedBtnOutlet.backgroundColor = UIColor.gray
        
        self.attachSpinner(value: true)
        self.feedbackModel.removeAll()
        dg.enter()
        self.getFeedBackDetails(FeedbackStatus.Drafts.rawValue) {
            self.dg.leave()
        }
        dg.notify(queue: .main) {
            self.attachSpinner(value: false)
        }
    }
    
    func getFeedBackDetails(_ state:String,_ completion:(()->())?) {
        
        if let userid = UserDefaults.standard.string(forKey: "UserId") {
            
            GFFirebaseManager.loadFeedsForUser(userId: userid, state) { (feeds) in
                
                if let feeds = feeds {
                    
                    self.feedbackModel.append(contentsOf: feeds)
                    if state == FeedbackStatus.Paid.rawValue {
                        
                        let value = feeds.reduce(0) {
                            $0 + ($1.price ?? 0)
                        }
                        self.walletBalanceLabel.text = String(format: "$%.2f",Float(value*Constants.UserWallet.userPercent))
                    }
                    if self.firstTimeLoad {
                        
                        self.firstTimeLoad = false
                    } else {
                        
                        if state == FeedbackStatus.Submitted.rawValue {
                            
                            self.feedbackModel = self.feedbackModel.sorted(by: { (a, b) -> Bool in
                                return a.restaurantTitle < b.restaurantTitle
                            })
                        }
                        self.tableView.reloadData()
                    }
                } else {
                    print("Error getting documents")
                }
                completion?()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedbackModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        
        cell.textLabel?.text = self.feedbackModel[indexPath.row].restaurantTitle
        cell.detailTextLabel?.text = self.feedbackModel[indexPath.row].address
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
        
        viewController.feedbackModel = self.feedbackModel[at]
        
        if self.feedbackModel[at].status  == FeedbackStatus.Drafts {
            
            viewController.isSubmitBtnHidden = false
            viewController.feedbackModel.status = .Drafts
            
        } else {
            
            viewController.isSubmitBtnHidden = true
        }
        let group = DispatchGroup()
        
        if let videoFiles = self.feedbackModel[at].videoFilName {
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
            
            if let imagefiles = self.feedbackModel[at].imageFileName {
                for path in imagefiles {
                    
                    group2.enter()
                    GFFirebaseManager.downloadImage(path) { (image) in
                        
                        if let image = image {
                            self.images.append(image)
                            print(self.images)
                            print(image)
                            print("sucess Image")
                            
                            if let videoFiles = self.feedbackModel[at].videoFilName {
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
                self.state = self.feedbackModel[at].status
                self.attachSpinner(value: false)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func draftsLoadFirstTime() {
        
        paidBtnOutlet.backgroundColor = UIColor.gray
        submittedBtnOutlet.backgroundColor = UIColor.gray
        
        dg.enter()
        self.getFeedBackDetails(FeedbackStatus.Paid.rawValue){
            
            self.dg.leave()
        }
        
        dg.notify(queue: .main) {
            self.feedbackModel.removeAll()
            self.dg.enter()
            self.getFeedBackDetails(FeedbackStatus.Drafts.rawValue){
                self.dg.leave()
            }
            self.dg.notify(queue: .main) {
                self.attachSpinner(value: false)
            }
        }
    }
}

