//
//  CreateTeamVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/11/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class CreateTeamVC: UIViewController {
    
    @IBOutlet weak var teamNumberField: UITextField!
    @IBOutlet weak var teamNameField: UITextField!
    @IBOutlet weak var teamCodeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamNumberField.becomeFirstResponder()
        
        teamNumberField.delegate = self
        teamNameField.delegate = self
        teamCodeField.delegate = self
        
    }
    @IBAction func createTeamClick(sender: UIButton) {
        httpRequest(morTeamURL+"/f/createTeam", type: "POST", data: ["id": teamCodeField.text!, "number": teamNameField.text!, "name": teamNameField.text!]){ responseText in
            if responseText == "success" {
                storage.setBool(false, forKey: "noTeam")
                dispatch_async(dispatch_get_main_queue(),{
                    let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("reveal")
                    self.showViewController(vc as! UIViewController, sender: vc)
                })
            }else{
                alert(title: "Failed", message: "Oops, something went wrong.", buttonText: "OK", viewController: self)
            }
        }
    }
    
}

extension CreateTeamVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.placeholder! == "Team Number" {
            teamNameField.becomeFirstResponder()
        }else if textField.placeholder! == "Team Name" {
            teamCodeField.becomeFirstResponder()
        }else if textField.placeholder! == "Team Code" {
            teamNumberField.becomeFirstResponder()
        }
        return true
    }
}