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
    
    @IBAction func registerClick(sender: UIButton) {
        if let url = NSURL(string: "http://www.morteam.com/signup") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    func login() {
        httpRequest(morTeamURL+"/f/login", type: "POST", data: [
            "username": usernameTextField.text!,
            "password": passwordTextField.text!
        ]) { responseText in
            if responseText == "inc/username" || responseText == "inc/password"{
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
                
                let storedUserProperties = ["username", "firstname", "lastname", "_id", "phone", "email", "profpicpath"]
                
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
                        dispatch_async(dispatch_get_main_queue(),{
                            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("reveal")
                            self.showViewController(vc as! UIViewController, sender: vc)
                        })
                    }
                }
                if !anyTeam {
                    storage.setBool(true, forKey: "noTeam")
                    dispatch_async(dispatch_get_main_queue(),{
                        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("void")
                        self.showViewController(vc as! UIViewController, sender: vc)
                    })

                }else{
                    storage.setBool(false, forKey: "noTeam")
                }

                
//                let storedProperties = ["_id", "username", "firstName", "lastName", "admin", "teamCode", "teamName", "teamNumber"]
//                
//                for (key, value):(String, JSON) in user {
//                    if storedProperties.indexOf(key) > -1 {
//                        storage.setObject(String(value), forKey: key)
//                    }
//                }
                
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
}