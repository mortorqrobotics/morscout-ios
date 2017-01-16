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
        let uPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: self.usernameTextField.frame.height))
        let pPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: self.passwordTextField.frame.height))
        usernameTextField.leftView = uPaddingView
        usernameTextField.leftViewMode = UITextFieldViewMode.always
        passwordTextField.leftView = pPaddingView
        passwordTextField.leftViewMode = UITextFieldViewMode.always
    }
    
    
    func login() {
        httpRequest(morTeamURL+"/f/login", type: "POST", data: ["username": usernameTextField.text!, "password":passwordTextField.text!]) { responseText in
            if responseText == "inc/username" || responseText == "inc/password"{
                DispatchQueue.main.async(execute: {
                    self.hideLoading()
                    alert(title: "Incorrect Username/Password", message: "This Username/Password combination does not exist.", buttonText: "OK", viewController: self)
                })
            }else if responseText == "fail"{
                DispatchQueue.main.async(execute: {
                    self.hideLoading()
                    alert(title: "Oops", message: "Something went wrong...", buttonText: "OK", viewController: self)
                })
                
            }else{
                //login successful
                let user = parseJSON(responseText)
                let storedUserProperties = ["username", "firstname", "lastname", "_id", "phone", "email", "profpicpath"]
                
                //store user properties in storage
                for (key, value):(String, JSON) in user {
                    if storedUserProperties.index(of: key) > -1 {
                        storage.set(String(describing: value), forKey: key)
                    }
                }
                
                var anyTeam = false
                
                if user["teams"].exists() && user["teams"].count > 0 {
                    if user["current_team"].exists() {
                        anyTeam = true
                        storage.set(user["current_team"]["id"].stringValue, forKey: "c_team")
                        storage.set(user["current_team"]["position"].stringValue, forKey: "c_team_position")
                        self.goTo(viewController: "reveal")
                    }
                }
                if !anyTeam {
                    storage.set(true, forKey: "noTeam")
                    self.goTo(viewController: "void")
                }else{
                    storage.set(false, forKey: "noTeam")
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
        }else if textField.placeholder! == "Password" {
            loginButton.setTitle("Loading...", for: UIControlState())
            loginButton.isEnabled = false
            login()
        }
        return true
    }
}
