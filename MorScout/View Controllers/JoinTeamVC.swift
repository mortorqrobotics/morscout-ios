//
//  JoinTeamVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/11/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class JoinTeamVC: UIViewController {
    
    @IBOutlet weak var teamCodeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamCodeField.becomeFirstResponder()
    }

    @IBAction func joinClick(_ sender: UIButton) {
        httpRequest(morTeamURL + "/teams/code/\(teamCodeField.text!)/join", type: "POST") { responseText in

            if responseText == "You already have a team" {
                alert(title: "Failed", message: "Seems like you already have a team.", buttonText: "OK", viewController: self)
            } else if responseText == "Team does not exist" {
                alert(title: "Team does not exist", message: "That team doesn't exist. Try another code.", buttonText: "OK", viewController: self)
            } else if responseText == "You are banned from this team" {
                alert(title: "Banned", message: "Jeez, looks like you were banned from this team.", buttonText: "OK", viewController: self)
            } else {
                let team = parseJSON(responseText)
                storage.set(false, forKey: "noTeam")
                storage.set(team["id"].stringValue, forKey: "team")
                storage.set("member", forKey: "position")
                self.goTo(viewController: "reveal")
            }
        }
    }
    
}
