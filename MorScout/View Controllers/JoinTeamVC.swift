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
        httpRequest(morTeamURL+"/f/joinTeam", type: "POST", data: ["team_id": teamCodeField.text!]) {responseText in
            if responseText == "success" {
                storage.set(false, forKey: "noTeam")
                DispatchQueue.main.async(execute: {
                    let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "reveal")
                    self.show(vc as! UIViewController, sender: vc)
                })
            }else if responseText == "fail" {
                alert(title: "Failed", message: "Oops, seems like somethings wrong.", buttonText: "OK", viewController: self)
            }else if responseText == "no such team" {
                alert(title: "Team Does Not Exist", message: "Sorry, but this team does not exist.", buttonText: "OK", viewController: self)
            }else if responseText == "banned" {
                alert(title: "You've been banned", message: "It seems like you;ve been banned from joining this team.", buttonText: "OK", viewController: self)
            }

        }
    }
    
}
