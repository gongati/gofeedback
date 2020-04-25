//
//  PreviewFeedbackViewController.swift
//  gofeedback
//
//  Created by OMNIADMIN on 30/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import Cosmos

class PreviewFeedbackViewController: GFBaseViewController {
    
    
  @IBOutlet weak var restuarantName: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var whatCanWeDoBetter: CosmosView!
    @IBOutlet weak var whatAreWeDoingGreat: CosmosView!
    @IBOutlet weak var howWeAreDoingCosmosView: CosmosView!
    @IBOutlet weak var commentsTxt: UITextView!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var submitBtnOulet: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var imageStackView: UIStackView!
  
    @IBOutlet weak var adminApprove: UIButton!
    @IBOutlet weak var adminRejecect: UIButton!
    
    var feedbackModel = FeedbackModel()
    var images:[UIImage]?
    var formImage:UIImage?
    var videoUrl:[URL]?
    var videoTag:[Int]?
    var adminFeedId:String?
    var isSubmitBtnHidden = false
    var isApprovedBtnHidden = true
    var isRejectbtnHidden = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.UIUpdate()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        super.view.backgroundColor = UIColor.white
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
        navigationController?.removeFromParent()
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        
        if let _ =  UserDefaults.standard.string(forKey: "UserId"),let feedId = self.feedbackModel.feedbackId {
            
            self.attachSpinner(value: true)
            self.feedbackModel.status = .Submitted
            
            self.feedbackUpdate(feedId)
            
        } else {
            
            self.popupAlert(title: "Alert", message: "Please Login to give Feedback", actionTitles: ["OK"], actions: [{ action in
                
                self.navigationController?.popViewController(animated: true)
                }])
        }
        
    }
    
    @IBAction func approvedPressed(_ sender: UIButton) {
        
        self.feedbackModel.status = .Approved
        
        if let feedId = self.adminFeedId {
            
            GFFirebaseManager.updateFeedStatus(feedId, self.feedbackModel) { (value) in
                
                if value {
                    
                 self.popupAlert(title: "Alert", message: "Approved", actionTitles: ["OK"], actions: [{ action in
                                    
                    self.navigationController?.popViewController(animated: true)
                                }])
                } else {
                    
                    self.popupAlert(title: "Error", message: "Error in saving Feedback", actionTitles: ["OK"], actions: [nil])
                }
            }
        }
    }
    
    
    @IBAction func rejectedPressed(_ sender: UIButton) {
     
        self.feedbackModel.status = .Rejected
        
         if let feedId = self.adminFeedId {
             
             GFFirebaseManager.updateFeedStatus(feedId, self.feedbackModel) { (value) in
                 
                 if value {
                     
                  self.popupAlert(title: "Alert", message: "Rejected", actionTitles: ["OK"], actions: [{ action in
                                     
                     self.navigationController?.popViewController(animated: true)
                                 }])
                 } else {
                     
                     self.popupAlert(title: "Error", message: "Error in saving Feedback", actionTitles: ["OK"], actions: [nil])
                 }
             }
         }
    }
    
    func moveToHomeVC() {
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    func moveToFeedback() {
        
        guard let viewController = UIStoryboard(name: "Feedback", bundle: nil).instantiateViewController(withIdentifier:  "GFNAVIGATETOLOGIN") as? GFLoginViewController else {
                   return
               }
               self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func feedbackUpdate(_ feedId:String) {
        
         GFFirebaseManager.updateFeedStatus(feedId, self.feedbackModel) { (value) in
            
            if value {
                 
                 print("Successfully saved data.")
                 self.popupAlert(title: "Alert", message: "Successfully saved data.", actionTitles: ["OK"], actions: [{ action in
                     
                     self.moveToHomeVC()
                 }])
            } else {
                self.popupAlert(title: "Error", message: "Error in saving Feedback", actionTitles: ["OK"], actions: [nil])
            }
        }
    }
    
    func UIUpdate() {
        
        restuarantName.text = feedbackModel.restaurantTitle
        addressLabel.text = feedbackModel.address
        cosmosView.rating = feedbackModel.rating
        whatCanWeDoBetter.rating = feedbackModel.whatCanWeDoBetterRating
        whatAreWeDoingGreat.rating = feedbackModel.whatAreWeDoingGreatRating
        howWeAreDoingCosmosView.rating = feedbackModel.howWeAreDoingRating
        commentsTxt.text = feedbackModel.comments
        
        if let images = self.images {
            for subview in images {
                let imageButton = UIButton()
                imageButton.addTarget(self, action: #selector(self.imageButtonPressed(sender:)), for: .touchUpInside)
                imageButton.setImage(subview, for: .normal)
                imageButton.tag = subview.hashValue
                
                imageButton.snp.makeConstraints { (make) in
                    
                    make.height.equalTo(self.imageStackView.frame.height)
                    make.width.equalTo(120)
                }
                self.imageStackView.addArrangedSubview(imageButton)
                
                self.imageStackView.translatesAutoresizingMaskIntoConstraints = false
            }
            self.scrollView.contentSize = CGSize(width: self.imageStackView.frame.width + 130, height: self.scrollView.frame.height)
        }
        if self.isSubmitBtnHidden {
            
            submitBtnOulet.isHidden = true
        }
        if self.isApprovedBtnHidden && self.isRejectbtnHidden {
            
            adminApprove.isHidden = true
            adminRejecect.isHidden = true
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        
        performSegue(withIdentifier: "ImageView", sender: sender.imageView?.image)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ImageView" {
            
            
            let vc = segue.destination as! PreviewImageViewController
            
            vc.image = sender as? UIImage
            
            if let sender = sender as? URL {
                
                vc.videoUrl = sender
                vc.isVideo = true
            }
        }
        
    }
        
  
    @objc func imageButtonPressed(sender: UIButton) {
        
        if let images = self.images {
            
            for i in 0..<images.count {
                
                if sender.tag == images[i].hashValue {
                    
                    if  self.videoTag?.count != 0 {
                        
                        for j in 0..<(self.videoTag?.count ?? 0) {
                            
                            if i == self.videoTag?[j] {
                                
                                performSegue(withIdentifier: "ImageView", sender: self.videoUrl?[j])
                                return
                            }
                        }
                        performSegue(withIdentifier: "ImageView", sender: sender.imageView?.image)
                    } else {
                        
                        performSegue(withIdentifier: "ImageView", sender: sender.imageView?.image)
                    }
                }
            }
        }
    }
}
