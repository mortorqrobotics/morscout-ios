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
    @IBOutlet weak var sortTabs: UISegmentedControl!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var teams = [Team]()
    var filteredTeams = [Team]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        teamsTable.delegate = self
        teamsTable.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        teamsTable.tableHeaderView = searchController.searchBar
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search Teams"
        
        checkConnectionAndSync()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if let teamsData = storage.objectForKey("teams") {
            let cachedTeams = NSKeyedUnarchiver.unarchiveObjectWithData(teamsData as! NSData) as? [Team]
            
            if cachedTeams!.count == 0 {
                alert(title: "No Data Found", message: "In order to load the data, you need to have connected to the internet at least once.", buttonText: "OK", viewController: self)
            }else{
                self.teams = cachedTeams!
            }
        }else{
            alert(title: "No Data Found", message: "In order to load the data, you need to have connected to the internet at least once.", buttonText: "OK", viewController: self)
        }
        
        if Reachability.isConnectedToNetwork() {
            getTeams()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.searchController.searchBar.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true)
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
                        
                        self.teams = []
                        
                        for (_, subJson):(String, JSON) in teams {
                            
                            let team_number = subJson["team_number"]
                            let team_name = subJson["nickname"]
                            let team_rank = teamRankings[String(team_number)]
                            
                            
                            
                            if let team_number = team_number.rawString(), let team_name = team_name.rawString() {
                                self.teams.append(Team(number: Int(team_number)!, name: team_name, rank: team_rank))
                            }
                            
                        }
                        
                        self.teams.sortInPlace { $0.number < $1.number }
                        
                        let teamsData = NSKeyedArchiver.archivedDataWithRootObject(self.teams)
                        storage.setObject(teamsData, forKey: "teams")
                    
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
        if searchController.active && searchController.searchBar.text != "" {
            return filteredTeams.count
        }else{
            return teams.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = teamsTable.dequeueReusableCellWithIdentifier("teamCell") as! TeamCell
        
        let team: Team
        if searchController.active && searchController.searchBar.text != "" {
            team = filteredTeams[indexPath.row]
        }else{
            team = teams[indexPath.row]
        }
        
        cell.teamNum.text = "Team \(team.number)"
        cell.teamName.text = team.name
        if let rank = team.rank {
            cell.teamRank.text = "Rank \(String(rank))"
        }else{
            cell.teamRank.text = "Rank N/A"
        }
        
        cell.backgroundColor = UIColorFromHex("F3F3F3")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showTeam", sender: indexPath)
        teamsTable.deselectRowAtIndexPath(indexPath, animated: true)
        self.searchController.searchBar.hidden = true
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredTeams = teams.filter { team in
            let containsName = team.name.lowercaseString.containsString(searchText.lowercaseString)
            let containsNumber = String(team.number).lowercaseString.containsString(searchText.lowercaseString)
            return containsName || containsNumber
        }
        
        teamsTable.reloadData()
    }
    
    @IBAction func changedSort(sender: UISegmentedControl) {
        switch sortTabs.selectedSegmentIndex {
        case 0:
           self.teams.sortInPlace { $0.number < $1.number }
            self.teamsTable.reloadData()
        case 1:
            self.teams.sortInPlace { $0.rank < $1.rank }
            self.teamsTable.reloadData()
        default:
            break
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showTeam") {
            if let teamsData = storage.objectForKey("teams") {
                let cachedTeams = NSKeyedUnarchiver.unarchiveObjectWithData(teamsData as! NSData) as? [Team]

                let teamVC = segue.destinationViewController as! TeamVC
                teamVC.teamNumber = cachedTeams![sender!.row].number
                teamVC.teamName = cachedTeams![sender!.row].name
            }
        }
    }
}

extension TeamsVC: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}