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
    
    @IBOutlet weak var whatCanWeDoBetter: UITextField!
    @IBOutlet weak var whatAreWeDoingGreat: UITextField!
    @IBOutlet weak var howWeAreDoing: UITextField!
    @IBOutlet weak var commentsTxt: UITextView!
    @IBOutlet weak var cosmosView: CosmosView!
    
    var restaurantTitle = ""
    var address = ""
    var rating : Double = 0
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
        
        cosmosView.didFinishTouchingCosmos = { rating in
            
            self.rating = rating
            print("rating \(rating)")
        }

    }
    @IBAction func cancelPressed(_ sender: UIButton) {
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        

        db.collection("Feedback").document(restaurantTitle).setData([
            Constants.FeedbackCommands.howWeAreDoing : self.howWeAreDoing.text as Any,
            Constants.FeedbackCommands.whatWeAreDoingGreat : self.whatAreWeDoingGreat.text as Any,
            Constants.FeedbackCommands.whatCanWeDoBetter : self.whatCanWeDoBetter.text as Any,
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
    
    func addDoneButtonOnKeyboard(){
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        whatCanWeDoBetter.inputAccessoryView = doneToolbar
        whatAreWeDoingGreat.inputAccessoryView = doneToolbar
        howWeAreDoing.inputAccessoryView = doneToolbar
        commentsTxt.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        whatCanWeDoBetter.resignFirstResponder()
        whatAreWeDoingGreat.resignFirstResponder()
        howWeAreDoing.resignFirstResponder()
        commentsTxt.resignFirstResponder()
    }
    
    func moveToHomeVC() {
        
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:  "GFNAVIGATEMENUHOME") as? HomeViewController else {
            return
        }
        viewController.searchItem = searchItem
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
