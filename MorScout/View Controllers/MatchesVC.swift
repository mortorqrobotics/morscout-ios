//
//  Matches.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/17/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit

class MatchesVC: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var matches = [Match]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        getMatches()
    }
    
    func getMatches() {
        httpRequest(baseURL+"/getMatchesForCurrentRegional", type: "POST") {responseText in
            if responseText != "fail" {
                let matches = parseJSON(responseText)
                
                for (_, subJson):(String, JSON) in matches {
                    let match_number = subJson["match_number"]
                    let time = subJson["time"]
                    
                    print(subJson)
                    print("##########")
                    
                    if let match_num = match_number.rawString(), let match_time = time.rawString() {
                        self.matches.append(Match(number: Int(match_num)!, time: NSDate(timeIntervalSince1970: Double(match_time)!), scouted: 0, redTeams: [], blueTeams: []))
                        
                    }
                    
                }
            }else{
                print("fail")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}