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
    var feedBackData : [String] = []
    
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
                        
                        self.feedBackData.append(document.documentID)
                        print(document.data()["Comments"] as! String)
                        print("\(document.documentID) => \(document.data())")
                    }
                    self.walletBalanceLabel.text = "$\(Float(self.feedBackData.count))"
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedBackData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.text = self.feedBackData[indexPath.row]
        return cell
    }
}

