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

class GFSignupViewController: GFBaseViewController {

    let viewModel = SignUpViewModel()
    let disposeBag = DisposeBag()
    
    var userID: String?
    var loginId:String?
    var code: String?
    var mobileNumber: String?
    
    @IBOutlet weak var firstNameTxt: GFWhiteButtonTextField!
    @IBOutlet weak var lastNameTxt: GFWhiteButtonTextField!

    
    @IBOutlet weak var addressTxtView: UITextView!

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
        if let code = self.code, let number = self.mobileNumber {
            
            countryCode.text = code
            mobileNumberTxt.text = number
        }
        
        self.addDoneButtonOnKeyboard()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc override func keyboardWillShow(notification: NSNotification) {
        
        if self.view.frame.origin.y == 0 {
            
            self.view.frame.origin.y -= 100
        }
    }
    
    func createViewModelBinding(){

        firstNameTxt.rx.text.orEmpty
            .bind(to: viewModel.firstNameViewModel.data)
            .disposed(by: disposeBag)

        lastNameTxt.rx.text.orEmpty
            .bind(to: viewModel.lastNameViewModel.data)
            .disposed(by: disposeBag)

        emailTxt.rx.text.orEmpty
            .bind(to: viewModel.emailIdViewModel.data)
            .disposed(by: disposeBag)
        
        addressTxtView.rx.text.orEmpty
        .bind(to: viewModel.addressViewModel.data)
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
                    
                    self.creatingDataBase()
                    self.attachSpinner(value: true)
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

    func creatingDataBase() {
        
        let userModel = UserModel(email: self.emailTxt.text ?? "", firstName: self.firstNameTxt.text ?? "", lastName: self.lastNameTxt.text ?? "", mobileNumber: "+" + (self.countryCode.text ?? "1") + " " + (self.mobileNumberTxt.text ?? "1234567890"), address: self.addressTxtView.text ?? "", userType: 0)
        
        GFFirebaseManager.creatingUserDetails(userModel: userModel){ (value) in
            
            if value {
                
                self.popupAlert(title: "Alert", message: "Successfully Registered", actionTitles: ["OK"], actions: [{ action in
                    
                    self.attachSpinner(value: false)
                    self.showOTPScreen()
                    }])
                
            } else {
                
                print("Error adding document: ")
                self.attachSpinner(value: false)
                self.popupAlert(title: "Alert", message: "Fail to register,try again", actionTitles: ["OK"], actions:[nil])
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

        addressTxtView.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        
        addressTxtView.resignFirstResponder()
        }
    
    func showOTPScreen() {
        
        self.performSegue(withIdentifier: "REGISTERTOOTP", sender: self.userID)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "REGISTERTOOTP") {
            
            if let secondViewController = segue.destination as? GFOTPViewController {
                
                if let userId = sender as? String {
                    
                    secondViewController.userID = userId
                    secondViewController.loginId = self.loginId
                }
            }
         }
    }
}
