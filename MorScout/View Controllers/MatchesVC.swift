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
        
        setup()
        getMatches()
    }
    
    func setup() {
        matchesTable.delegate = self
        matchesTable.dataSource = self
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func getMatches() {
        httpRequest(baseURL+"/getMatchesForCurrentRegional", type: "POST") {responseText in
            if responseText != "fail" {
                let matches = parseJSON(responseText)
                
                for (_, subJson):(String, JSON) in matches {
                    let match_number = subJson["match_number"]
                    let time = subJson["time"]
                    var redTeams = [String]()
                    var blueTeams = [String]()
                    for i in 0...2 {
                        var redTeam = String(subJson["alliances"]["red"]["teams"][i])
                        redTeam = redTeam[3...redTeam.characters.count-1]
                        redTeams.append(redTeam)
                        
                        var blueTeam = String(subJson["alliances"]["blue"]["teams"][i])
                        blueTeam = blueTeam[3...blueTeam.characters.count-1]
                        blueTeams.append(blueTeam)
                    }
                    
                    if let match_num = match_number.rawString(), let match_time = time.rawString() {
                        self.matches.append(Match(number: Int(match_num)!, time: NSDate(timeIntervalSince1970: Double(match_time)!), scouted: 0, redTeams: redTeams, blueTeams: blueTeams))
                        
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
        cell.matchNum.text = "Match " + String(matches[indexPath.row].number)
        cell.matchTime.text = time
        cell.redTeam1.text = matches[indexPath.row].redTeams[0]
        cell.redTeam2.text = matches[indexPath.row].redTeams[1]
        cell.redTeam3.text = matches[indexPath.row].redTeams[2]
        cell.blueTeam1.text = matches[indexPath.row].blueTeams[0]
        cell.blueTeam2.text = matches[indexPath.row].blueTeams[1]
        cell.blueTeam3.text = matches[indexPath.row].blueTeams[2]
        
        cell.backgroundColor = UIColorFromHex("f9f9f9")
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showMatch", sender: indexPath)
        matchesTable.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}