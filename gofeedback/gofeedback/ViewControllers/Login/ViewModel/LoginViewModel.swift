//
//  LoginViewModel.swift
//  Genfare
//
//  Created by vishnu on 20/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class LoginViewModel {
    
    let model : LoginModel = LoginModel()
    let disposebag = DisposeBag()
    
    // Initialise ViewModel's
    let emailIdViewModel = EmailIdViewModel()
    let passwordViewModel = PasswordViewModel()
    
    // Fields that bind to our view's
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let walletNeeded : Variable<Bool> = Variable(false)
    let showWalletList: Variable<Array> = Variable([])
    let showRetrieveWallet: Variable<Bool> = Variable(false)
    let smsAuthNeeded: Variable<Bool> = Variable(false)
    let showAccountBased: Variable<Bool> = Variable(false)
    let showCardBased: Variable<Bool> = Variable(false)
    let errorMsg : Variable<String> = Variable("")
    let logoutUser : Variable<Bool> = Variable(false)
    
    var walletJson:[String:Any]?
    
    func validateCredentials() -> Bool{
        return emailIdViewModel.validateCredentials() && passwordViewModel.validateCredentials();
    }
    
    func formErrorString() -> String {
        if(emailIdViewModel.errorValue.value != ""){
            return emailIdViewModel.errorValue.value ?? ""
        }else if(passwordViewModel.errorValue.value != ""){
            return passwordViewModel.errorValue.value ?? ""
        }
        
        return ""
    }

    func loginUser() {
        isLoading.value = true
        model.email = emailIdViewModel.data.value
        model.password = passwordViewModel.data.value

//        let loginService = GFLoginService(username: model.email, password: model.password)
//        loginService.loginUser { [unowned self] (success, error) in
//            self.isLoading.value = false
//            if success {
//                self.refreshToken()
//            }else{
//                print(error)
//                self.errorMsg.value = error as! String
//            }
//        }
    }
    
    func refreshToken(){
        isLoading.value = true
        
//        GFRefreshAuthToken.refresh { [unowned self] (success, error) in
//            self.isLoading.value = false
//
//            if success {
//                self.fetchWallets()
//            }else{
//                self.errorMsg.value = error as! String
//            }
//        }
    }
    
}
