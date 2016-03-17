//
//  ProfileVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/7/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

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
    
    var userId = storage.stringForKey("_id")!
    var firstName = ""
    var lastName = ""
    var position = ""
    var profilePicturePath = ""
    var isScoutCaptain = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoutCaptainSwitch.enabled = false
        
        assigmentsScrollView.addSubview(container)
        
        if let savedFirstName = storage.stringForKey("firstname"), let savedLastName = storage.stringForKey("lastname") {
            profileName.text = savedFirstName + " " + savedLastName
        }
        
        if let savedProfPicPath = storage.stringForKey("profpicpath") {
            profileImageView.kf_setImageWithURL(NSURL(string: morTeamURL+savedProfPicPath)!)
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
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    func getUserData(_id: String) {
        httpRequest(morTeamURL+"/f/getUser", type: "POST", data: ["_id": _id]) {responseText in
            if responseText != "fail" {
                let user = parseJSON(responseText)
                
                self.firstName = String(user["firstname"])
                self.lastName = String(user["lastname"])
                self.position = String(user["current_team"]["position"])
                self.profilePicturePath = String(user["profpicpath"])
                self.isScoutCaptain = Bool(user["current_team"]["scoutCaptain"])
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.profileName.text = self.firstName + " " + self.lastName
                    self.profileImageView.kf_setImageWithURL(NSURL(string: morTeamURL+self.profilePicturePath+"-300")!)
                    self.scoutCaptainSwitch.setOn(self.isScoutCaptain, animated: false)
                    self.scoutCaptainSwitch.enabled = self.isScoutCaptain || self.position == "admin" || self.position == "leader"
                })
                
                self.scoutCaptainSwitch.addTarget(self, action: Selector("scoutCaptainStateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
            }
        }
    }
    
    func getUserStats(_id: String) {
        httpRequest(baseURL+"/getUserStats", type: "POST", data: ["userID": _id]) { responseText in
            
            let stats = parseJSON(responseText)
            dispatch_async(dispatch_get_main_queue(),{
                self.matchReports.text = String(stats["matchesScouted"])
                self.pitReports.text = String(stats["pitsScouted"])
                self.teamsScouted.text = String(stats["teamsScouted"])
            })
        }
    }
    
    func getUserTasks(_id: String) {
        httpRequest(baseURL+"/showTasks", type: "POST", data: ["scoutID": _id]) { responseText in
            
            let tasks = parseJSON(responseText)
            dispatch_async(dispatch_get_main_queue(),{
                
                var completedMatches = [String]()
                for(_, subJson):(String, JSON) in tasks["matchesDone"] {
                    completedMatches.append(String(subJson))
                }
                if completedMatches.count == 0 {
                    self.assignmentsComplete.text = "none"
                }else{
                    self.assignmentsComplete.text = completedMatches.joinWithSeparator(", ")
                }
                
                
                var incompleteMatches = [String]()
                for(_, subJson):(String, JSON) in tasks["matchesNotDone"] {
                    incompleteMatches.append(String(subJson))
                }
                if incompleteMatches.count == 0 {
                    self.assignmentsIncomplete.text = "none"
                }else{
                    self.assignmentsIncomplete.text = incompleteMatches.joinWithSeparator(", ")
                }
                
                if tasks["assignments"].array?.count == 0 {
                    let label = UILabel(frame: CGRectMake(0, self.assignmentsTopMargin, self.view.frame.width, 21))
                    label.text = "None"
                    label.font = UIFont(name: "Helvetica", size: 17)
                    self.container.addSubview(label)
                }else{
                    for(_, subJson):(String, JSON) in tasks["assignments"] {
                        print(subJson)
                        print("----")
                        let label = UILabel(frame: CGRectMake(0, self.assignmentsTopMargin, self.view.frame.width, 21))
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
    
    func scoutCaptainStateChanged(switchState: UISwitch) {
        if switchState.on {
            httpRequest(baseURL+"/setSC", type: "POST", data: ["isSC": "true", "userID": userId]) { responseText in
                
                if responseText == "fail" {
                    alert(title: "Failed", message: "Oops. Something went wrong.", buttonText: "OK", viewController: self)
                    dispatch_async(dispatch_get_main_queue(),{
                        self.scoutCaptainSwitch.setOn(false, animated: true)
                    })
                }
            }
        }else{
            httpRequest(baseURL+"/setSC", type: "POST", data: ["isSC": "false", "userID": userId]) { responseText in
                
                if responseText == "fail" {
                    alert(title: "Failed", message: "Oops. Something went wrong.", buttonText: "OK", viewController: self)
                    dispatch_async(dispatch_get_main_queue(),{
                        self.scoutCaptainSwitch.setOn(true, animated: true)
                    })
                }
            }
        }
    }
    
}