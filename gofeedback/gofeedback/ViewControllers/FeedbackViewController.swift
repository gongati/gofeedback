//
//  ViewController.swift
//  gofeedback
//
//  Created by Vishnu Vardhan Reddy G on 04/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import  Cosmos
import Firebase

class FeedbackViewController: GFBaseViewController {

    @IBOutlet weak var restuarantName: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var whatCanWeDoBetter: CosmosView!
    @IBOutlet weak var whatAreWeDoingGreat: CosmosView!
    @IBOutlet weak var howWeAreDoingCosmosView: CosmosView!
    @IBOutlet weak var commentsTxt: UITextView!
    @IBOutlet weak var cosmosView: CosmosView!
    
    var restaurantTitle = ""
    var address = ""
    var rating : Double = 3
    var whatCanWeDoBetterRating: Double = 3
    var whatAreWeDoingGreatRating: Double = 3
    var howWeAreDoingRating: Double = 3

    var searchItem = ""
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        restuarantName.text = restaurantTitle
        addressLabel.text = address
        
        self.addDoneButtonOnKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        super.view.backgroundColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.ratingsUpadate()

    }
    @IBAction func cancelPressed(_ sender: UIButton) {
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        
        if let userId = UserDefaults.standard.string(forKey: "UserId")  {
            
            self.feedbackUpdate(userId)
        } else {
            
            self.popupAlert(title: "Alert", message: "Please Login to give Feedback", actionTitles: ["OK"], actions: [{ action in
                
                self.navigationController?.popViewController(animated: true)
                }])
        }
        
    }
    
    func addDoneButtonOnKeyboard(){
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        commentsTxt.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        whatCanWeDoBetter.resignFirstResponder()
        whatAreWeDoingGreat.resignFirstResponder()
        howWeAreDoingCosmosView.resignFirstResponder()
        commentsTxt.resignFirstResponder()
    }
    
    func moveToHomeVC() {
        
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "GFNAVIGATEMENUHOME") as? HomeViewController else {
            return
        }
        viewController.searchItem = searchItem
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    func moveToLogin() {
        
        guard let viewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier:  "GFNAVIGATETOLOGIN") as? GFLoginViewController else {
                   return
               }
               self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    func ratingsUpadate() {
        
        
        cosmosView.didFinishTouchingCosmos = { rating in

            self.rating = rating
        }
        
        whatCanWeDoBetter.didFinishTouchingCosmos = { rating in
            
            self.whatCanWeDoBetterRating = rating
        }
        
        
        whatAreWeDoingGreat.didFinishTouchingCosmos = { rating in
            
            self.whatAreWeDoingGreatRating = rating
        }
        
        howWeAreDoingCosmosView.didFinishTouchingCosmos = { rating in
            
            self.howWeAreDoingRating = rating
        }
    }
    
    func feedbackUpdate(_ userId:String) {
        
        db.collection("Feedback").document(userId).setData([
            Constants.FeedbackCommands.restuarantName : self.restaurantTitle,
            Constants.FeedbackCommands.restuarantAddress : self.address,
            Constants.FeedbackCommands.howWeAreDoing : self.howWeAreDoingRating,
            Constants.FeedbackCommands.whatWeAreDoingGreat : self.whatAreWeDoingGreatRating,
            Constants.FeedbackCommands.whatCanWeDoBetter : self.whatCanWeDoBetterRating,
            Constants.FeedbackCommands.comments : self.commentsTxt.text,
            Constants.FeedbackCommands.rating : self.rating
        ]) { (error) in
            if let err = error {
                self.popupAlert(title: "Error", message: err.localizedDescription, actionTitles: ["OK"], actions: [nil])
            } else {
                print("Successfully saved data.")
                self.popupAlert(title: "Alert", message: "Successfully saved data.", actionTitles: ["OK"], actions: [{ action in
                    
                    self.moveToHomeVC()
                }])
           }
        }
    }
}
