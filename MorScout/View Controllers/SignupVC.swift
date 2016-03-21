//
//  SignupVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/20/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class SignupVC: UIViewController {
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameField.becomeFirstResponder()
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        phoneField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func signupClick(sender: UIButton) {
        submitButton.setTitle("Loading...", forState: .Normal)
        submitButton.enabled = false
        submitButton.backgroundColor = UIColor.lightGrayColor()
        if isValidEmail(emailField.text!) {
            if isValidPhone(phoneField.text!) {
                if validNames() {
                    if passwordsMatch() {
                        httpRequest(morTeamURL+"/f/createUser", type: "POST", data: ["firstname": firstNameField.text!.capitalized, "lastname": lastNameField.text!.capitalized, "username": usernameField.text!, "email": emailField.text!, "password": passwordField.text!, "password_confirm": confirmPasswordField.text!, "phone": trimPhone(phoneField.text!)]) { responseText in
                            dispatch_async(dispatch_get_main_queue(),{
                                if responseText == "success" {
                                        self.performSegueWithIdentifier("showLogin", sender: nil)
                                }else if responseText == "exists" {
                                    self.submitButton.setTitle("Submit", forState: .Normal)
                                    self.submitButton.enabled = true
                                    self.submitButton.backgroundColor = UIColorFromHex("FFA500")
                                    alert(title: "User exists", message: "The username, email address or phone number you entered has been registered.", buttonText: "OK", viewController: self)
                                }else{
                                    self.submitButton.setTitle("Submit", forState: .Normal)
                                    self.submitButton.enabled = true
                                    self.submitButton.backgroundColor = UIColorFromHex("FFA500")
                                    alert(title: "Failed", message: "Oops, something went wrong", buttonText: "OK", viewController: self)
                                }
                            })
                        }
                    }else{
                        submitButton.setTitle("Submit", forState: .Normal)
                        submitButton.enabled = true
                        submitButton.backgroundColor = UIColorFromHex("FFA500")
                        alert(title: "Passwords don't match", message: "Make sure you entered both password fields correctly.", buttonText: "OK", viewController: self)
                    }
                }else{
                    submitButton.setTitle("Submit", forState: .Normal)
                    submitButton.enabled = true
                    submitButton.backgroundColor = UIColorFromHex("FFA500")
                    alert(title: "Invalid Name/Username", message: "Make sure you enter a first name, last name and username.", buttonText: "OK", viewController: self)
                }
            }else{
                submitButton.setTitle("Submit", forState: .Normal)
                submitButton.enabled = true
                submitButton.backgroundColor = UIColorFromHex("FFA500")
                alert(title: "Invalid Phone", message: "Looks like your phone number is not valid.", buttonText: "OK", viewController: self)
            }
        }else{
            submitButton.setTitle("Submit", forState: .Normal)
            submitButton.enabled = true
            submitButton.backgroundColor = UIColorFromHex("FFA500")
            alert(title: "Invalid Email", message: "Looks like your email address is not valid.", buttonText: "OK", viewController: self)
        }
    }
    
    func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    func isValidPhone(testStr: String) -> Bool {
        let stringArray = testStr.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let newString = stringArray.joinWithSeparator("")
        return newString.characters.count == 10
    }
    func trimPhone(str: String) -> String {
        let stringArray = str.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        return stringArray.joinWithSeparator("")
    }
    func validNames() -> Bool {
        return !(firstNameField.text == "" || lastNameField.text == "" || usernameField.text == "")
    }
    func passwordsMatch() -> Bool {
        return passwordField.text == confirmPasswordField.text
    }
}

extension SignupVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.placeholder! == "First Name" {
            lastNameField.becomeFirstResponder()
        }else if textField.placeholder! == "Last Name" {
            usernameField.becomeFirstResponder()
        }else if textField.placeholder! == "Username" {
            emailField.becomeFirstResponder()
        }else if textField.placeholder! == "Email" {
            passwordField.becomeFirstResponder()
        }else if textField.placeholder! == "Password" {
            confirmPasswordField.becomeFirstResponder()
        }else if textField.placeholder! == "Confirm Password" {
            phoneField.becomeFirstResponder()
        }else if textField.placeholder! == "Phone" {
            firstNameField.becomeFirstResponder()
        }
        
        return true
    }
}