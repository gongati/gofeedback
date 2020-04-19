//
//  AdminFeedsViewController.swift
//  gofeedback
//
//  Created by OMNIADMIN on 19/04/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import Firebase

class AdminFeedsViewController: GFBaseViewController,UITableViewDataSource,UITableViewDelegate {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var feedBackDataTitle : [String] = []
    var feedBackData = [[String:Any]]()
    var totalFeedback = [[String:[[String:Any]]]]()
    var images = [UIImage]()
    var videoUrl = [URL]()
    var videotag = [Int]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.feedBackData.removeAll()
        self.feedBackDataTitle.removeAll()
        self.totalFeedback.removeAll()
        self.attachSpinner(value: true)
        getFeedsDetails()
    }
    
    func getFeedsDetails() {
        
        db.collection("Feedback").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let dg = DispatchGroup()
                for document in querySnapshot!.documents {
                    
                    dg.enter()
                    let docId = document.documentID
                    print("\(document.documentID) => \(document.data())")
                    self.db.collection("Feedback").document(document.documentID).collection(FeedbackStatus.Submitted.rawValue).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            var data = [[String:Any]]()
                            for document in querySnapshot!.documents {
                                
                                self.feedBackDataTitle.append(document.documentID)
                                print(document.data()["Comments"] as! String)
                                print("\(document.documentID) => \(document.data())")
                                self.feedBackData.append(document.data())
                                data.append(document.data())
                            }
                            self.totalFeedback.append([docId:data])
                            data.removeAll()
                        }
                        dg.leave()
                    }
                }
                dg.notify(queue: .main) {
                    
                    self.tableView.reloadData()
                    self.attachSpinner(value: false)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.feedBackDataTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdminFeedsCell", for: indexPath)
        
        if self.feedBackData[indexPath.row][Constants.FeedbackCommands.status] as? String ?? "" == FeedbackStatus.Paid.rawValue {
       
            cell.backgroundColor = UIColor.green
        } else if self.feedBackData[indexPath.row][Constants.FeedbackCommands.status] as? String ?? "" == FeedbackStatus.Rejected.rawValue {
            
            cell.backgroundColor = UIColor.red
        }
         cell.textLabel?.text = self.feedBackDataTitle[indexPath.row]
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
        
        var userId = ""
        
        for i in 0..<totalFeedback.count {
            
            for value in totalFeedback[i].values {
                
                for j in 0..<value.count{
                    if value[j][Constants.FeedbackCommands.restuarantName] as? String ?? "" == self.feedBackData[at][Constants.FeedbackCommands.restuarantName] as? String ?? "" {
                        for id in totalFeedback[i] {
                            
                            userId = id.key
                        }
                    }
                }
            }
        }
        guard let viewController = UIStoryboard(name: "Feedback", bundle: nil).instantiateViewController(withIdentifier:  "PreviewFeedbackViewController") as? PreviewFeedbackViewController else {
            return
        }
        viewController.feedbackModel.address = self.feedBackData[at][Constants.FeedbackCommands.restuarantAddress] as? String ?? ""
        viewController.feedbackModel.restaurantTitle = self.feedBackData[at][Constants.FeedbackCommands.restuarantName] as? String ?? ""
        viewController.feedbackModel.rating = self.feedBackData[at][Constants.FeedbackCommands.rating] as? Double ?? 0
        viewController.feedbackModel.whatAreWeDoingGreatRating = self.feedBackData[at][Constants.FeedbackCommands.whatWeAreDoingGreat] as? Double ?? 0
        viewController.feedbackModel.howWeAreDoingRating = self.feedBackData[at][Constants.FeedbackCommands.howWeAreDoing] as? Double ?? 0
        viewController.feedbackModel.whatCanWeDoBetterRating = self.feedBackData[at][Constants.FeedbackCommands.whatCanWeDoBetter] as? Double ?? 0
        viewController.feedbackModel.comments = self.feedBackData[at][Constants.FeedbackCommands.comments] as? String ?? ""
        
        viewController.feedbackModel.isSubmitBtnHidden = true
        if (self.feedBackData[at][Constants.FeedbackCommands.status] as? String ?? "" != FeedbackStatus.Rejected.rawValue)  && self.feedBackData[at][Constants.FeedbackCommands.status] as? String ?? "" != FeedbackStatus.Paid.rawValue {
            
            viewController.feedbackModel.isApprovedBtnHidden = false
            viewController.feedbackModel.isRejectbtnHidden = false
        }
        let group = DispatchGroup()
         
        
        for path in self.feedBackData[at][Constants.FeedbackCommands.images] as? [String] ?? [""] {
            
            group.enter()
            
            
        let pathReferenceOfImages = storage.reference(withPath: path )
        pathReferenceOfImages.getData(maxSize: 1 * 1024 * 1024) { data, error in
           
            if error != nil {
                // Uh-oh, an error occurred!
                print(error?.localizedDescription)
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                if let image = image {
                self.images.append(image)
                print(self.images)
                print(image)
                print("sucess Image")
                    
                    for tag in self.feedBackData[at][Constants.FeedbackCommands.thumnailTag] as? [String] ?? [""] {
                        if path == ("Images/"+tag+".jpg"){
                            
                            self.videotag.append(self.images.count - 1)
                        }
                        
                    }
                }
            }
            group.leave()
        }
        
        }
        
        group.notify(queue: .main) {
            
            let group2 = DispatchGroup()
            
            for path in self.feedBackData[at][Constants.FeedbackCommands.videoUrl] as? [String] ?? [""] {
                 group2.enter()
            let pathReferenceOfVideos = self.storage.reference(withPath: path )
            pathReferenceOfVideos.downloadURL { url, error in
                
                    if error != nil {
                        print(error?.localizedDescription)
                    } else {
                        // Data for "images/island.jpg" is returned
                        if let url = url {
                            
                        self.videoUrl.append(url)
                        print("sucess Form")
                        print(viewController.videoUrl)
                        }
                    }
                    
                     group2.leave()
            }
        }
            
            group2.notify(queue: .main) {
                
                viewController.images = self.images
                viewController.videoUrl = self.videoUrl
                viewController.videoTag = self.videotag
                viewController.adminUserId = userId
                print(viewController.images)
                print("navigation")
                self.attachSpinner(value: false)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}
