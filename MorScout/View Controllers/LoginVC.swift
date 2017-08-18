//
//  LoginVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/16/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class LoginVC: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        setup()
        usernameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickLogin(_ sender: UIButton) {
        showLoading()
        login()
    }
    
    func setup() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        //set paddings for text fields
        let usernamePaddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: 8, height: self.usernameTextField.frame.height))
        let passwordPaddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: 8, height: self.passwordTextField.frame.height))
        usernameTextField.leftView = usernamePaddingView
        usernameTextField.leftViewMode = UITextFieldViewMode.always
        passwordTextField.leftView = passwordPaddingView
        passwordTextField.leftViewMode = UITextFieldViewMode.always
    }
    
    
    func login() {
        httpRequest(morTeamURL + "/login", type: "POST", data: [
            "username": usernameTextField.text!,
            "password": passwordTextField.text!,
            "rememberMe": "true",
        ]) { responseText in

            if responseText == "Invalid login credentials"{
                DispatchQueue.main.async(execute: {
                    self.hideLoading()
                    alert(title: "Incorrect Username/Password", message: "This Username/Password combination does not exist.", buttonText: "OK", viewController: self)
                })
            } else {
                //login successful
                let user = parseJSON(responseText)
                let storedUserProperties = [
                    "username", "firstname", "lastname",
                    "_id", "phone", "email", "profpicpath",]
                
                //store user properties in storage
                for (key, value):(String, JSON) in user {
                    if storedUserProperties.index(of: key) > -1 {
                        storage.set(String(describing: value), forKey: key)
                    }
                }

                if user["team"].exists() {
                    storage.set(false, forKey: "noTeam")
                    storage.set(user["team"]["id"].stringValue, forKey: "team")
                    storage.set(user["position"].stringValue, forKey: "position")
                    self.goTo(viewController: "reveal")
                } else {
                    storage.set(true, forKey: "noTeam")
                    self.goTo(viewController: "void")
                }
                
            }
        }
    }
    
    func showLoading() {
        loginButton.setTitle("Loading...", for: UIControlState())
        loginButton.isEnabled = false
    }
    
    func hideLoading() {
        self.loginButton.setTitle("Login", for: UIControlState())
        self.loginButton.isEnabled = true
    }
}

extension LoginVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.placeholder! == "Username/Email" {
            passwordTextField.becomeFirstResponder()
        } else if textField.placeholder! == "Password" {
            showLoading()
            login()
        }
        return true
    }

}
