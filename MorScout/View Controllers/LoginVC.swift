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
    @IBAction func clickLogin(sender: UIButton) {
        login()
    }
    
    override func viewDidLoad() {
        setup()
    }
    
    func setup() {
        
//        self.view.backgroundColor = UIColor.blackColor()
        
        loginButton.backgroundColor = UIColorFromHex("#FFA500")
        
        usernameTextField.layer.borderWidth = 2
        usernameTextField.layer.borderColor = UIColorFromHex("#FFA500").CGColor
        passwordTextField.layer.borderWidth = 2
        passwordTextField.layer.borderColor = UIColorFromHex("#FFA500").CGColor
        
        usernameTextField.attributedPlaceholder = NSAttributedString(string:"Username",
            attributes:[NSForegroundColorAttributeName: UIColorFromHex("#FFA500", alpha: 0.8)])
        passwordTextField.attributedPlaceholder = NSAttributedString(string:"Password",
            attributes:[NSForegroundColorAttributeName: UIColorFromHex("#FFA500", alpha: 0.8)])

    }
    
    func login() {
        httpRequest(baseURL+"/login", type: "POST", data: [
            "username": usernameTextField.text!,
            "password": passwordTextField.text!
        ]) { responseText in
            if responseText == "inc_username" || responseText == "inc_password"{
                dispatch_async(dispatch_get_main_queue(),{
                    let alert = UIAlertController(title: "Wrong Username/Password", message: "This Username/Password combination does not exist.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }else if responseText == "fail"{
                dispatch_async(dispatch_get_main_queue(),{
                    let alert = UIAlertController(title: "Oops", message: "Something went wrong...", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                
            }else{
                //login successful
                
                let user = parseJSON(responseText)
                
                let storedProperties = ["_id", "username", "firstName", "lastName", "admin", "teamCode", "teamName", "teamNumber"]
                
                for (key, value):(String, JSON) in user {
                    if storedProperties.indexOf(key) > -1 {
                        storage.setObject(String(value), forKey: key)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(),{
                    let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("reveal")
                    self.showViewController(vc as! UIViewController, sender: vc)
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
}