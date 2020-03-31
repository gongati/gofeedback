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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.getFeedBackDetails()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    

    @IBAction func backPressed(_ sender: UIButton) {
        
        self.moveToHomeVC()
    }
    
    func moveToHomeVC() {
        
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "GFNAVIGATEMENUHOME") as? HomeViewController else {
            return
        }
        self.navigationController?.pushViewController(viewController, animated: true)
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
    }
    
    func moveToPreviewVC(_ at:Int) {
        
        let pathReferenceOfImages = storage.reference(withPath: self.feedBackData[at][Constants.FeedbackCommands.images] as? String ?? "" )
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
         group.enter()
        pathReferenceOfImages.getData(maxSize: 1 * 1024 * 1024) { data, error in
           
            if error != nil {
                // Uh-oh, an error occurred!
                print(error?.localizedDescription)
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                viewController.images = image
                print(image)
                print("sucess Image")
                print(viewController.images)
            }
            group.leave()
        }
        
        group.enter()
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
                
                 group.leave()
        }
        
        group.notify(queue: .main) {
            
           print("navigation")
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
 
}

