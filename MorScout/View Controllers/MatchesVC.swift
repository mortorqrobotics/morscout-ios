//
//  Matches.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/17/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit

class MatchesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var matchesTable: UITableView!
    
    var matches = [Match]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        matchesTable.delegate = self
        matchesTable.dataSource = self
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
                    
                    if let match_num = match_number.rawString(), let match_time = time.rawString() {
                        self.matches.append(Match(number: Int(match_num)!, time: NSDate(timeIntervalSince1970: Double(match_time)!), scouted: 0, redTeams: [], blueTeams: []))
                        
                    }
                    
                }
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.matchesTable.reloadData()
                })
                
            }else{
                print("fail")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = matchesTable.dequeueReusableCellWithIdentifier("matchCell") as! MatchCell
        let time = timeFromNSDate(matches[indexPath.row].time)
        cell.matchNum.text = "Match " + String(matches[indexPath.row].number) /* + " - " + time + " - Scouted 2 of 6" */
        cell.matchTime.text = time
        cell.redTeam1.text = "1515"
        cell.redTeam2.text = "1616"
        cell.redTeam3.text = "1717"
        cell.blueTeam1.text = "1818"
        cell.blueTeam2.text = "1919"
        cell.blueTeam3.text = "2020"
        
        cell.backgroundColor = UIColorFromHex("444444")
        
        return cell
    }
    
}