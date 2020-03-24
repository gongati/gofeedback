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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createViewModelBinding()
        createCallbacks()
//        self.imgUser.image =  UIImage(named: "\(Utilities.tenantId().lowercased())LogoBig")

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyStylesAndColors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                self.creatingDataBase()
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
        
        ref = db.collection("users").addDocument(data: [
            "First Name": self.firstNameTxt.text as Any,
            "Last Name": self.lastNameTxt.text as Any,
            "email": self.emailTxt.text as Any
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.ref!.documentID)")
            }
        }
    }
}
