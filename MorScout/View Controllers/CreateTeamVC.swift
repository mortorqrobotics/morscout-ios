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
    @IBAction func createTeamClick(_ sender: UIButton) {
        httpRequest(morTeamURL + "/teams", type: "POST", data: [
            "id": teamCodeField.text!,
            "number": teamNumberField.text!,
            "name": teamNameField.text!
        ]){ responseText in

            if responseText == "You already have a team" {
                alert(
                    title: "Failed",
                    message: "Looks like you already have a team.",
                    buttonText: "OK", viewController: self)
            } else if responseText == "Invalid team number" {
                alert(
                    title: "Invalid team number",
                    message: "Try another team number.",
                    buttonText: "OK", viewController: self)
            } else if responseText == "Team code is taken" {
                alert(
                    title: "Failed",
                    message: "That team code is already taken. Try another one.",
                    buttonText: "OK", viewController: self)
            } else {
                let team = parseJSON(responseText)
                storage.set(false, forKey: "noTeam")
                storage.set(team["id"].stringValue, forKey: "team")
                storage.set("leader", forKey: "position")
                self.goTo(viewController: "reveal")
            }
        }
    }
    
}

extension CreateTeamVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.placeholder! == "Team Number" {
            teamNameField.becomeFirstResponder()
        } else if textField.placeholder! == "Team Name" {
            teamCodeField.becomeFirstResponder()
        } else if textField.placeholder! == "Team Code" {
            teamNumberField.becomeFirstResponder()
        }
        return true
    }
}
