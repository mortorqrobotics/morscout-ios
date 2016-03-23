//
//  LoginVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/16/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit

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
    
    @IBAction func clickLogin(sender: UIButton) {
        showLoading()
        login()
    }
    
    func setup() {
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        //set paddings for text fields
        let uPaddingView = UIView(frame: CGRectMake(0, 0, 8, self.usernameTextField.frame.height))
        let pPaddingView = UIView(frame: CGRectMake(0, 0, 8, self.passwordTextField.frame.height))
        usernameTextField.leftView = uPaddingView
        usernameTextField.leftViewMode = UITextFieldViewMode.Always
        passwordTextField.leftView = pPaddingView
        passwordTextField.leftViewMode = UITextFieldViewMode.Always
    }
    
    
    func login() {
        httpRequest(morTeamURL+"/f/login", type: "POST", data: ["username": usernameTextField.text!, "password":passwordTextField.text!]) { responseText in
            if responseText == "inc/username" || responseText == "inc/password"{
                dispatch_async(dispatch_get_main_queue(),{
                    self.hideLoading()
                    alert(title: "Incorrect Username/Password", message: "This Username/Password combination does not exist.", buttonText: "OK", viewController: self)
                })
            }else if responseText == "fail"{
                dispatch_async(dispatch_get_main_queue(),{
                    self.hideLoading()
                    alert(title: "Oops", message: "Something went wrong...", buttonText: "OK", viewController: self)
                })
                
            }else{
                //login successful
                let user = parseJSON(responseText)
                let storedUserProperties = ["username", "firstname", "lastname", "_id", "phone", "email", "profpicpath"]
                
                //store user properties in storage
                for (key, value):(String, JSON) in user {
                    if storedUserProperties.indexOf(key) > -1 {
                        storage.setObject(String(value), forKey: key)
                    }
                }
                
                var anyTeam = false
                
                if user["teams"].isExists() && user["teams"].count > 0 {
                    if user["current_team"].isExists() {
                        anyTeam = true
                        storage.setObject(String(user["current_team"]["id"]), forKey: "c_team")
                        storage.setObject(String(user["current_team"]["position"]), forKey: "c_team_position")
                        self.goTo(viewController: "reveal")
                    }
                }
                if !anyTeam {
                    storage.setBool(true, forKey: "noTeam")
                    self.goTo(viewController: "void")
                }else{
                    storage.setBool(false, forKey: "noTeam")
                }
            }
        }
    }
    
    func showLoading() {
        loginButton.setTitle("Loading...", forState: .Normal)
        loginButton.enabled = false
    }
    
    func hideLoading() {
        self.loginButton.setTitle("Login", forState: .Normal)
        self.loginButton.enabled = true
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.placeholder! == "Username/Email" {
            passwordTextField.becomeFirstResponder()
        }else if textField.placeholder! == "Password" {
            loginButton.setTitle("Loading...", forState: .Normal)
            loginButton.enabled = false
            login()
        }
        return true
    }
}
