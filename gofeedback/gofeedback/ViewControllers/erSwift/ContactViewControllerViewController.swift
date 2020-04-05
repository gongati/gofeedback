//
//  ContactViewControllerViewController.swift
//  gofeedback
//
//  Created by OMNIADMIN on 31/03/20.
//  Copyright © 2020 Vishnu. All rights reserved.
//

import UIKit
import MessageUI

class ContactViewControllerViewController: GFBaseViewController,MFMailComposeViewControllerDelegate {
    
    
    @IBOutlet weak var nameTxtF: GFWhiteButtonTextField!
    @IBOutlet weak var emailTxt: GFWhiteButtonTextField!
    @IBOutlet weak var commentsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addDoneButtonOnKeyboard()
    }
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        let exp1 = commentsTextView.text + "\n\nWith Regards, \n"
        let exp2 = (nameTxtF?.text ?? "Anonymous") + "\n"
        print(exp1 + exp2 + (emailTxt?.text ?? ""))
        
        if MFMailComposeViewController.canSendMail() {
            
            let emailTitle = "Feedback"
            let messageBody = (exp1 + exp2 + (emailTxt?.text ?? ""))
            let toRecipents = ["kalebupatan7@gmail.com"]
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(emailTitle)
            mc.setMessageBody(messageBody, isHTML: false)
            mc.setToRecipients(toRecipents)
            
            self.present(mc, animated: true, completion: nil)
        } else {
            
            self.popupAlert(title: "Alert", message: "Login to mail for sending comments.", actionTitles: ["OK"], actions: [nil])
        }
    }

    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            self.popupAlert(title: "ALert", message: "Mail Canceled", actionTitles: ["OK"], actions: [nil])
            print("Mail cancelled")
        case MFMailComposeResult.saved.rawValue:
            self.popupAlert(title: "ALert", message: "Mail saved", actionTitles: ["OK"], actions: [nil])
            print("Mail saved")
        case MFMailComposeResult.sent.rawValue:
            self.popupAlert(title: "ALert", message: "Mail sent", actionTitles: ["OK"], actions: [nil])
            print("Mail sent")
        case MFMailComposeResult.failed.rawValue:
            self.popupAlert(title: "ALert", message: "Mail sent failure: \( [error!.localizedDescription])", actionTitles: ["OK"], actions: [nil])
            print("Mail sent failure: %@", [error!.localizedDescription])
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func addDoneButtonOnKeyboard() {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        commentsTextView.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        
        commentsTextView.resignFirstResponder()
    }
}
