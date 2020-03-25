//
//  GFSignupViewController.swift
//  Genfare
//
//  Created by omniwzse on 04/10/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase

class GFSignupViewController: GFBaseViewController {

    let viewModel = SignUpViewModel()
    let disposeBag = DisposeBag()
    let db = Firestore.firestore()
    var ref: DocumentReference? = nil
    
    @IBOutlet weak var firstNameTxt: GFWhiteButtonTextField!
    @IBOutlet weak var lastNameTxt: GFWhiteButtonTextField!
    @IBOutlet weak var passwordTxt1: GFWhiteButtonTextField!
    @IBOutlet weak var passwordTxt2: GFWhiteButtonTextField!
    @IBOutlet weak var emailTxt: GFWhiteButtonTextField!
    @IBOutlet weak var signUpBtn: GFMenuButton!
    @IBOutlet var imgUser: UIImageView!

    @IBOutlet weak var signInNtn: UIButton!
    
    @IBOutlet weak var countryCode: GFWhiteButtonTextField!
    @IBOutlet weak var mobileNumberTxt: GFWhiteButtonTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createViewModelBinding()
        createCallbacks()
//        self.imgUser.image =  UIImage(named: "\(Utilities.tenantId().lowercased())LogoBig")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.addDoneButtonOnKeyboard()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyStylesAndColors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   @objc func keyboardWillShow(notification: NSNotification) {
    
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 100
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func createViewModelBinding(){

        firstNameTxt.rx.text.orEmpty
            .bind(to: viewModel.firstNameViewModel.data)
            .disposed(by: disposeBag)

        lastNameTxt.rx.text.orEmpty
            .bind(to: viewModel.lastNameViewModel.data)
            .disposed(by: disposeBag)

        passwordTxt1.rx.text.orEmpty
            .bind(to: viewModel.passwordViewModel.data)
            .disposed(by: disposeBag)

        passwordTxt2.rx.text.orEmpty
            .bind(to: viewModel.passwordViewModel2.data)
            .disposed(by: disposeBag)

        emailTxt.rx.text.orEmpty
            .bind(to: viewModel.emailIdViewModel.data)
            .disposed(by: disposeBag)

        signUpBtn.rx.tap.do(onNext:  { [unowned self] in
            self.view.resignFirstResponder()
        }).subscribe(onNext: { [unowned self] in
            if self.viewModel.validateCredentials() {
                self.viewModel.signupUser()
                
            }else{
                self.showErrorMessage(message: self.viewModel.formErrorString())
            }
        }).disposed(by: disposeBag)
    }

    func createCallbacks (){
        // success
        viewModel.isSuccess.asObservable()
            .bind{ value in
                //Present create wallet controller
                if value {
                    
                    self.signUpBtn.isHidden = true
                    self.creatingDataBase()
                }
            }.disposed(by: disposeBag)

        // Loading
        viewModel.isLoading.asObservable()
            .bind{[unowned self] value in
                self.attachSpinner(value: value)
            }.disposed(by: disposeBag)

        // errors
        viewModel.errorMsg.asObservable()
            .bind {[unowned self] errorMessage in
                // Show error
                self.showErrorMessage(message: errorMessage)
            }.disposed(by: disposeBag)

    }
    func applyStylesAndColors(){
        self.signUpBtn.backgroundColor = UIColor(hexString:Utilities.colorHexString(resourceId: "BigButtonBGColor" )!)
    }
    
    func creatingDataBase() {
        
        ref = db.collection((self.countryCode.text ?? "+1") + "" + (self.mobileNumberTxt.text ?? "1234567890")).addDocument(data: [
            "First Name": self.firstNameTxt.text as Any,
            "Last Name": self.lastNameTxt.text as Any,
            "email": self.emailTxt.text as Any,
            "Mobile Number": (self.countryCode.text ?? "+1") + "" + (self.mobileNumberTxt.text ?? "1234567890")
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.ref!.documentID)")
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

        countryCode.inputAccessoryView = doneToolbar
        mobileNumberTxt.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        countryCode.resignFirstResponder()
        mobileNumberTxt.resignFirstResponder()
    }
}
