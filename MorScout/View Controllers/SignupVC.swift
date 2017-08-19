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
    
    @IBAction func signupClick(_ sender: UIButton) {
        showLoading()
        if isValidEmail(emailField.text!) {
            if isValidPhone(phoneField.text!) {
                if validNames() {
                    if passwordsMatch() {
                        httpRequest(morTeamURL + "/users", type: "POST", data: [
                            "firstname": firstNameField.text!.capitalized,
                            "lastname": lastNameField.text!.capitalized,
                            "username": usernameField.text!,
                            "email": emailField.text!,
                            "password": passwordField.text!,
                            "phone": trimPhone(phoneField.text!)
                        ]) { responseText in
                            DispatchQueue.main.async(execute: {
                                if responseText == "Invalid email" {
                                    alert(
                                        title: "Invalid email",
                                        message: "Please try again.",
                                        buttonText: "OK", viewController: self)
                                    self.hideLoading()
                                } else if responseText == "Invalid phone number" {
                                    alert(
                                        title: "Invalid phone number",
                                        message: "Please try again.",
                                        buttonText: "OK", viewController: self)
                                    self.hideLoading()
                                } else if responseText == "Username is taken" {
                                    alert(
                                        title: "Username is taken",
                                        message: "Please try again.",
                                        buttonText: "OK", viewController: self)
                                    self.hideLoading()
                                } else if responseText == "Email is taken" {
                                    alert(
                                        title: "Username is taken",
                                        message: "Please try again.",
                                        buttonText: "OK", viewController: self)
                                    self.hideLoading()
                                } else if responseText == "Phone number is taken" {
                                    alert(
                                        title: "Phone number is taken",
                                        message: "Please try again.",
                                        buttonText: "OK", viewController: self)
                                    self.hideLoading()
                                } else if responseText == "Email is taken" {
                                    alert(
                                        title: "Email address is taken",
                                        message: "Please try again.",
                                        buttonText: "OK", viewController: self)
                                    self.hideLoading()
                                } else {
                                    self.performSegue(withIdentifier: "showLogin", sender: nil)
                                }
                            })
                        }
                    } else {
                        self.hideLoading()
                        alert(
                            title: "Passwords don't match",
                            message: "Make sure you entered both password fields correctly.",
                            buttonText: "OK", viewController: self)
                    }
                } else {
                    self.hideLoading()
                    alert(
                        title: "Invalid Name/Username",
                        message: "Make sure you enter a first name, last name and username.",
                        buttonText: "OK", viewController: self)
                }
            } else {
                self.hideLoading()
                alert(
                    title: "Invalid Phone",
                    message: "Looks like your phone number is not valid.",
                    buttonText: "OK", viewController: self)
            }
        } else {
            self.hideLoading()
            alert(
                title: "Invalid Email",
                message: "Looks like your email address is not valid.",
                buttonText: "OK", viewController: self)
        }
    }
    
    func isValidEmail(_ testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    func isValidPhone(_ testStr: String) -> Bool {
        let stringArray = testStr.components(
            separatedBy: CharacterSet.decimalDigits.inverted)
        let newString = stringArray.joined(separator: "")
        return newString.characters.count == 10
    }
    func trimPhone(_ str: String) -> String {
        let stringArray = str.components(
            separatedBy: CharacterSet.decimalDigits.inverted)
        return stringArray.joined(separator: "")
    }
    func validNames() -> Bool {
        return !(firstNameField.text == "" || lastNameField.text == "" || usernameField.text == "")
    }
    func passwordsMatch() -> Bool {
        return passwordField.text == confirmPasswordField.text
    }

    /**
        Changes signup button appearance to signify that
        the user is in the process of being registered
     */
    func showLoading() {
        submitButton.setTitle("Loading...", for: UIControlState())
        submitButton.isEnabled = false
        submitButton.backgroundColor = UIColor.lightGray
    }

    /**
        Restores signup button to original appearance
     */
    func hideLoading() {
        self.submitButton.setTitle("Submit", for: UIControlState())
        self.submitButton.isEnabled = true
        self.submitButton.backgroundColor = UIColorFromHex("FFA500")
    }
}

extension SignupVC: UITextFieldDelegate {

    /*
        This is called when the return button on
        the keyboard is pressed.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.placeholder! == "First Name" {
            lastNameField.becomeFirstResponder()
        } else if textField.placeholder! == "Last Name" {
            usernameField.becomeFirstResponder()
        } else if textField.placeholder! == "Username" {
            emailField.becomeFirstResponder()
        } else if textField.placeholder! == "Email" {
            passwordField.becomeFirstResponder()
        } else if textField.placeholder! == "Password" {
            confirmPasswordField.becomeFirstResponder()
        } else if textField.placeholder! == "Confirm Password" {
            phoneField.becomeFirstResponder()
        } else if textField.placeholder! == "Phone" {
            firstNameField.becomeFirstResponder()
        }
        return true
    }
}
