//
//  ProfileVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/7/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProfileVC: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var assigmentsScrollView: UIScrollView!
    @IBOutlet weak var scoutCaptainSwitch: UISwitch!
    
    @IBOutlet weak var matchReports: UILabel!
    @IBOutlet weak var pitReports: UILabel!
    @IBOutlet weak var teamsScouted: UILabel!
    @IBOutlet weak var assignmentsComplete: UILabel!
    @IBOutlet weak var assignmentsIncomplete: UILabel!
    @IBOutlet weak var assignmentCompletion: UILabel!
    
    var container = UIView()
    var assignmentsTopMargin: CGFloat = 0
    
    var userId = storage.string(forKey: "_id")!
    var firstName = ""
    var lastName = ""
    var position = ""
    var profilePicturePath = ""
    var isScoutCaptain = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoutCaptainSwitch.isEnabled = false
        
        assigmentsScrollView.addSubview(container)
        
        if let savedFirstName = storage.string(forKey: "firstname"), let savedLastName = storage.string(forKey: "lastname") {
            profileName.text = savedFirstName + " " + savedLastName
        }
        
        if let savedProfPicPath = storage.string(forKey: "profpicpath") {
            profileImageView.kf.setImage(with: URL(string: "http://www.morteam.com" + savedProfPicPath)!, options: [.requestModifier(modifier)])
        }
        
        if Reachability.isConnectedToNetwork() {
            getUserData(userId)
            getUserStats(userId)
            getUserTasks(userId)
        }else{
            alert(title: "No Internet Connection", message: "Could not load all user data", buttonText: "OK", viewController: self)
        }
        
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector((SWRevealViewController.revealToggle) as (SWRevealViewController) -> (Void) -> Void)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    func getUserData(_ _id: String) {
        httpRequest(morTeamURL + "/users/id/\(_id)", type: "GET") { responseText in
            if responseText != "null" {
                let user = parseJSON(responseText)
                
                self.firstName = String(describing: user["firstname"])
                self.lastName = String(describing: user["lastname"])
                self.position = String(describing: user["position"])
                self.profilePicturePath = String(describing: user["profpicpath"])
                self.isScoutCaptain = user["scoutCaptain"].boolValue
                
                DispatchQueue.main.async(execute: {
                    self.profileName.text = self.firstName + " " + self.lastName
                    self.profileImageView.kf.setImage(
                        with: URL(string: "http://www.morteam.com" + self.profilePicturePath + "-300")!,
                        options: [.requestModifier(modifier)])
                    self.scoutCaptainSwitch.setOn(self.isScoutCaptain, animated: false)
                    self.scoutCaptainSwitch.isEnabled = self.isScoutCaptain || self.position == "admin" || self.position == "leader"
                })
                
                self.scoutCaptainSwitch.addTarget(self, action: #selector(ProfileVC.scoutCaptainStateChanged(_:)), for: UIControlEvents.valueChanged)
            }
        }
    }
    
    func getUserStats(_ _id: String) {
        httpRequest(baseURL+"/getUserStats", type: "POST", data: ["userID": _id]) { responseText in
            
            let stats = parseJSON(responseText)
            DispatchQueue.main.async(execute: {
                self.matchReports.text = stats["matchesScouted"].stringValue
                self.pitReports.text = stats["pitsScouted"].stringValue
                self.teamsScouted.text = stats["teamsScouted"].stringValue
            })
        }
    }
    
    func getUserTasks(_ _id: String) {
        httpRequest(baseURL+"/showTasks", type: "POST", data: ["scoutID": _id]) { responseText in
            
            let tasks = parseJSON(responseText)
            DispatchQueue.main.async(execute: {
                
                var completedMatches = [String]()
                for(_, subJson):(String, JSON) in tasks["matchesDone"] {
                    completedMatches.append(subJson.stringValue)
                }
                if completedMatches.count == 0 {
                    self.assignmentsComplete.text = "none"
                }else{
                    self.assignmentsComplete.text = completedMatches.joined(separator: ", ")
                }
                
                
                var incompleteMatches = [String]()
                for(_, subJson):(String, JSON) in tasks["matchesNotDone"] {
                    incompleteMatches.append(subJson.stringValue)
                }
                if incompleteMatches.count == 0 {
                    self.assignmentsIncomplete.text = "none"
                }else{
                    self.assignmentsIncomplete.text = incompleteMatches.joined(separator: ", ")
                }
                
                if tasks["assignments"].array?.count == 0 {
                    let label = UILabel(frame: CGRect(x: 0, y: self.assignmentsTopMargin, width: self.view.frame.width, height: 21))
                    label.text = "None"
                    label.font = UIFont(name: "Helvetica", size: 17)
                    self.container.addSubview(label)
                }else{
                    for(_, subJson):(String, JSON) in tasks["assignments"] {
                        print(subJson)
                        print("----")
                        let label = UILabel(frame: CGRect(x: 0, y: self.assignmentsTopMargin, width: self.view.frame.width, height: 21))
                        label.text = "• From match \(subJson["startMatch"]) to \(subJson["endMatch"]), \(subJson["alliance"]) alliance, Team \(subJson["teamSection"])"
                        label.font = UIFont(name: "Helvetica", size: 14.5)
                        self.container.addSubview(label)
                        self.assignmentsTopMargin += label.frame.height + 7
                    }
                }
                
                let totalMatches = (tasks["matchesDone"].array?.count)! + (tasks["matchesNotDone"].array?.count)!
                self.assignmentCompletion.text = String((tasks["matchesDone"].array?.count)!) + "/" + String(totalMatches)
            })
        }
    }
    
    func scoutCaptainStateChanged(_ switchState: UISwitch) {
        if switchState.isOn {
            httpRequest(baseURL+"/setSC", type: "POST", data: ["isSC": "true", "userID": userId]) { responseText in
                
                if responseText == "fail" {
                    alert(title: "Failed", message: "Oops. Something went wrong.", buttonText: "OK", viewController: self)
                    DispatchQueue.main.async(execute: {
                        self.scoutCaptainSwitch.setOn(false, animated: true)
                    })
                }
            }
        }else{
            httpRequest(baseURL+"/setSC", type: "POST", data: ["isSC": "false", "userID": userId]) { responseText in
                
                if responseText == "fail" {
                    alert(title: "Failed", message: "Oops. Something went wrong.", buttonText: "OK", viewController: self)
                    DispatchQueue.main.async(execute: {
                        self.scoutCaptainSwitch.setOn(true, animated: true)
                    })
                }
            }
        }
    }
    
}
