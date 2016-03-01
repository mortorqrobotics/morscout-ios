//
//  TeamsVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/17/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit

class TeamsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var teamsTable: UITableView!
    
    var teams = [Team]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        teamsTable.delegate = self
        teamsTable.dataSource = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        getTeams()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getTeams() {
        httpRequest(baseURL+"/getTeamListForRegional", type: "POST") {teams in
            if teams != "fail" {
                let teams = parseJSON(teams)
                httpRequest(baseURL+"/getRankingsForRegional", type: "POST"){rankings in
                    if rankings != "fail" {
                        
                        let rankings = parseJSON(rankings)
                        var teamRankings = [String: Int]()
                        if rankings.count > 0 {
                            for (i, subJson):(String, JSON) in rankings {
                                if Int(i) > 0 {
                                    teamRankings[String(subJson[1])] = Int(String(subJson[0]))
                                }
                            }
                        }
                        for (_, subJson):(String, JSON) in teams {
                            
                            let team_number = subJson["team_number"]
                            let team_name = subJson["nickname"]
                            let team_rank = teamRankings[String(team_number)]
                            
                            
                            
                            if let team_number = team_number.rawString(), let team_name = team_name.rawString() {
                                self.teams.append(Team(number: Int(team_number)!, name: team_name, rank: team_rank))
                            }
                            
                        }
                        
                        
                    
                        dispatch_async(dispatch_get_main_queue(),{
                            self.teamsTable.reloadData()
                        })
                        
                    }
                }
                
            }else{
                print("fail")
            }
        }

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = teamsTable.dequeueReusableCellWithIdentifier("teamCell") as! TeamCell
        cell.teamNum.text = "Team \(teams[indexPath.row].number)"
        cell.teamName.text = teams[indexPath.row].name
        if let rank = teams[indexPath.row].rank {
            cell.teamRank.text = "Rank \(String(rank))"
        }else{
            cell.teamRank.text = "Rank N/A"
        }
        cell.backgroundColor = UIColorFromHex("F3F3F3")
        
        return cell
    }
    
}