//
//  WalletViewController.swift
//  gofeedback
//
//  Created by OMNIADMIN on 29/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import Firebase

class WalletViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var walletBalanceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()

    let storage = Storage.storage()
    var feedBackDataTitle : [String] = []
    var feedBackData = [[String:Any]]()
    var images = [UIImage]()
    var videoUrl = [URL]()
    var videotag = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getFeedBackDetails(FeedbackStatus.Submitted.rawValue,FeedbackStatus.Paid.rawValue)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func submiteedPressed(_ sender: UIButton) {
        
        self.feedBackData.removeAll()
        self.feedBackDataTitle.removeAll()
        self.getFeedBackDetails(FeedbackStatus.Submitted.rawValue,FeedbackStatus.Submitted.rawValue)
        self.getFeedBackDetails(FeedbackStatus.Submitted.rawValue,FeedbackStatus.Paid.rawValue)

    }
    
    @IBAction func paidPressed(_ sender: UIButton) {
        
       self.feedBackData.removeAll()
        self.feedBackDataTitle.removeAll()
        self.getFeedBackDetails(FeedbackStatus.Submitted.rawValue,FeedbackStatus.Paid.rawValue)
    }
    
    @IBAction func draftsPressed(_ sender: UIButton) {
        
       self.feedBackData.removeAll()
        self.feedBackDataTitle.removeAll()
        self.getFeedBackDetails(FeedbackStatus.Drafts.rawValue,FeedbackStatus.Drafts.rawValue)
    }
    

    @IBAction func pendingPressed(_ sender: UIButton) {
        
       self.feedBackData.removeAll()
        self.feedBackDataTitle.removeAll()
        self.getFeedBackDetails(FeedbackStatus.Submitted.rawValue,FeedbackStatus.Submitted.rawValue)
    }
    
    func getFeedBackDetails(_ collectionStatus: String,_ state:String) {
        
        if let userid = UserDefaults.standard.string(forKey: "UserId") {
            

            let docRef = db.collection("Feedback").document(userid).collection(collectionStatus).whereField(Constants.FeedbackCommands.status, isEqualTo: state)
            
            docRef.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    for document in querySnapshot!.documents {
                        
                        self.feedBackDataTitle.append(document.documentID)
                        print(document.data()["Comments"] as! String)
                        print("\(document.documentID) => \(document.data())")
                        self.feedBackData.append(document.data())
                    }
                    if state == FeedbackStatus.Paid.rawValue {
                        
                    self.walletBalanceLabel.text = "$\(Float(self.feedBackDataTitle.count))"
                    }
                    self.tableView.reloadData()
                }
            }
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedBackDataTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)

        cell.textLabel?.text = self.feedBackDataTitle[indexPath.row]
        cell.detailTextLabel?.text = self.feedBackData[indexPath.row][Constants.FeedbackCommands.restuarantAddress] as? String ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        viewController.feedbackModel.address = self.feedBackData[at][Constants.FeedbackCommands.restuarantAddress] as? String ?? ""
        viewController.feedbackModel.restaurantTitle = self.feedBackData[at][Constants.FeedbackCommands.restuarantName] as? String ?? ""
        viewController.feedbackModel.rating = self.feedBackData[at][Constants.FeedbackCommands.rating] as? Double ?? 0
        viewController.feedbackModel.whatAreWeDoingGreatRating = self.feedBackData[at][Constants.FeedbackCommands.whatWeAreDoingGreat] as? Double ?? 0
        viewController.feedbackModel.howWeAreDoingRating = self.feedBackData[at][Constants.FeedbackCommands.howWeAreDoing] as? Double ?? 0
        viewController.feedbackModel.whatCanWeDoBetterRating = self.feedBackData[at][Constants.FeedbackCommands.whatCanWeDoBetter] as? Double ?? 0
        viewController.feedbackModel.comments = self.feedBackData[at][Constants.FeedbackCommands.comments] as? String ?? ""
        
        if self.feedBackData[at][Constants.FeedbackCommands.status]  as? String ?? ""  == FeedbackStatus.Drafts.rawValue {
            
            viewController.feedbackModel.isSubmitBtnHidden = false
            viewController.feedbackModel.status = .Drafts
            
        } else {
            
            viewController.feedbackModel.isSubmitBtnHidden = true
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
                print(viewController.images)
           print("navigation")
            self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
 
}

