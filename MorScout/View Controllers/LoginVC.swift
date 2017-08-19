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

class LoginVC: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        usernameTextField.becomeFirstResponder()
    }

    func setupView() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self

        // set paddings for text fields
        let usernamePaddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: 8, height: self.usernameTextField.frame.height))
        let passwordPaddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: 8, height: self.passwordTextField.frame.height))
        usernameTextField.leftView = usernamePaddingView
        usernameTextField.leftViewMode = UITextFieldViewMode.always
        passwordTextField.leftView = passwordPaddingView
        passwordTextField.leftViewMode = UITextFieldViewMode.always
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickLogin(_ sender: UIButton) {
        showLoading()
        login()
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
                    if storedUserProperties.contains(key) {
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
                    self.goTo(viewController: "void") // this page gives users the option
                                                      // to join or create a team.
                }
                
            }
        }
    }

    /**
        Changes login button appearance to signify that
        the user is in the process of being logged in
     */
    func showLoading() {
        loginButton.setTitle("Loading...", for: UIControlState())
        loginButton.isEnabled = false
    }

    /**
        Reverts login button to original appearance.
    */
    func hideLoading() {
        self.loginButton.setTitle("Login", for: UIControlState())
        self.loginButton.isEnabled = true
    }
}

extension LoginVC: UITextFieldDelegate {

    /*
        This is called when the return button on
        the keyboard is pressed.
    */
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
