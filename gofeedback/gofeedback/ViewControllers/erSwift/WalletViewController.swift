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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.getFeedBackDetails()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func getFeedBackDetails() {
        
        if let userid = UserDefaults.standard.string(forKey: "UserId") {
            

            let docRef = db.collection("Feedback").document(userid).collection("Ratings")
            
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
                    self.walletBalanceLabel.text = "$\(Float(self.feedBackDataTitle.count))"
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        moveToPreviewVC(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func moveToPreviewVC(_ at:Int) {
        
        
        let pathReferenceOfForm = storage.reference(withPath: self.feedBackData[at][Constants.FeedbackCommands.form] as? String ?? "" )
        
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
                }
            }
            group.leave()
        }
        
        }
        
        group.notify(queue: .main) {
            
            let group2 = DispatchGroup()
            group2.enter()
            pathReferenceOfForm.getData(maxSize: 1 * 1024 * 1024) { data, error in
                
                    if error != nil {
                        print(error?.localizedDescription)
                    } else {
                        // Data for "images/island.jpg" is returned
                        let dataForm = UIImage(data: data!)
                        print(dataForm)
                        viewController.formImage = dataForm
                        print("sucess Form")
                        print(viewController.formImage)
                    }
                    
                     group2.leave()
            }
            
             group2.notify(queue: .main) {
                
                viewController.images = self.images
                print(viewController.images)
           print("navigation")
            self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
 
}

