//
//  TeamsVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/17/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if let teamsData = storage.object(forKey: "teams") {
            let cachedTeams = NSKeyedUnarchiver.unarchiveObject(with: teamsData as! Data) as? [Team]
            
            if cachedTeams!.count == 0 {
                alert(title: "No Data Found", message: "In order to load the data, you need to have connected to the internet at least once.", buttonText: "OK", viewController: self)
            }else{
                self.teams = cachedTeams!
            }
        }
        
        if Reachability.isConnectedToNetwork() {
            getTeams()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.searchController.searchBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
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
                                    teamRankings[subJson[1].stringValue] = subJson[0].intValue
                                }
                            }
                        }
                        
                        self.teams = []
                        
                        for (_, subJson):(String, JSON) in teams {
                            
                            let team_number = subJson["team_number"]
                            let team_name = subJson["nickname"]
                            let team_rank = teamRankings[String(describing: team_number)]
                            
                            
                            
                            if let team_number = team_number.rawString(), let team_name = team_name.rawString() {
                                self.teams.append(Team(number: Int(team_number)!, name: team_name, rank: team_rank))
                            }
                            
                        }
                        
                        self.teams.sort { $0.number < $1.number }
                        
                        let teamsData = NSKeyedArchiver.archivedData(withRootObject: self.teams)
                        storage.set(teamsData, forKey: "teams")
                    
                        DispatchQueue.main.async(execute: {
                            self.teamsTable.reloadData()
                        })
                        
                    }
                }
                
            }else{
                print("fail")
            }
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredTeams.count
        }else{
            return teams.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = teamsTable.dequeueReusableCell(withIdentifier: "teamCell") as! TeamCell
        
        let team: Team
        if searchController.isActive && searchController.searchBar.text != "" {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showTeam", sender: indexPath)
        teamsTable.deselectRow(at: indexPath, animated: true)
        self.searchController.searchBar.isHidden = true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredTeams = teams.filter { team in
            let containsName = team.name.lowercased().contains(searchText.lowercased())
            let containsNumber = String(team.number).lowercased().contains(searchText.lowercased())
            return containsName || containsNumber
        }
        
        teamsTable.reloadData()
    }
    
    @IBAction func changedSort(_ sender: UISegmentedControl) {
        switch sortTabs.selectedSegmentIndex {
        case 0:
           self.teams.sort { $0.number < $1.number }
            self.teamsTable.reloadData()
        case 1:
            self.teams.sort { $0.rank < $1.rank }
            self.teamsTable.reloadData()
        default:
            break
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showTeam") {
            let team: Team
            if searchController.isActive && searchController.searchBar.text != "" {
                team = filteredTeams[(sender! as AnyObject).row]
            }else{
                team = teams[(sender! as AnyObject).row]
            }

            let teamVC = segue.destination as! TeamVC
            teamVC.teamNumber = team.number
            teamVC.teamName = team.name
            
        }
    }
}

extension TeamsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
