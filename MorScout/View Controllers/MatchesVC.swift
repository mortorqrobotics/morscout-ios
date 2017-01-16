//
//  Matches.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/17/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class MatchesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var matchesTable: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var matches = [Match]()
    var filteredMatches = [Match]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        checkConnectionAndSync()
        loadMatchesFromCache()
        
        if Reachability.isConnectedToNetwork() {
            getMatches()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.searchController.searchBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setup() {
        matchesTable.delegate = self
        matchesTable.dataSource = self
        setupMenu(menuButton)
        
        //setup search
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        matchesTable.tableHeaderView = searchController.searchBar
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search Teams in Matches"
    }
    
    func getMatches() {
        httpRequest(baseURL+"/getMatchesForCurrentRegional", type: "POST") { responseText in
            if responseText != "fail" {
                let matches = parseJSON(responseText)
                self.matches = []
                for (_, subJson):(String, JSON) in matches {
                    let match_number = subJson["match_number"]
                    let time = subJson["time"]
                    var redTeams = [String]()
                    var blueTeams = [String]()
                    
                    for i in 0...2 {
                        var redTeam = subJson["alliances"]["red"]["teams"][i].stringValue
                        //remove "frc" from the beginning of team number
                        redTeam = String(redTeam.characters.dropFirst(3))
                        redTeams.append(redTeam)
                        
                        var blueTeam = subJson["alliances"]["blue"]["teams"][i].stringValue
                        //remove "frc" from the beginning of team number
                        blueTeam = String(blueTeam.characters.dropFirst(3))
                        blueTeams.append(blueTeam)
                    }
                    
                    if let match_num = match_number.rawString(), let match_time = time.rawString() {
                        if let match_time = Double(match_time) {
                            self.matches.append(Match(number: Int(match_num)!, time: Date(timeIntervalSince1970: match_time), redTeams: redTeams, blueTeams: blueTeams))
                        }else{
                            self.matches.append(Match(number: Int(match_num)!, time: nil, redTeams: redTeams, blueTeams: blueTeams))
                        }
                    }
                    
                }
                
                self.matches.sort { $0.time!.compare($1.time!) == .orderedAscending }
                
                let matchesData = NSKeyedArchiver.archivedData(withRootObject: self.matches)
                storage.set(matchesData, forKey: "matches")
                
                DispatchQueue.main.async(execute: {
                    self.matchesTable.reloadData()
                })
                
            }else{
                print("fail")
            }
        }
    }
    
    func loadMatchesFromCache() {
        if let matchesData = storage.object(forKey: "matches") {
            let cachedMatches = NSKeyedUnarchiver.unarchiveObject(with: matchesData as! Data) as? [Match]
            
            if cachedMatches!.count == 0 {
                alert(title: "No Data Found", message: "In order to load the data, you need to have connected to the internet at least once.", buttonText: "OK", viewController: self)
            }else{
                self.matches = cachedMatches!
            }
        }
    }
    
    //MARK: - TableView methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredMatches.count
        }else{
            return matches.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = matchesTable.dequeueReusableCell(withIdentifier: "matchCell") as! MatchCell
        
        let match: Match
        if searchController.isActive && searchController.searchBar.text != "" {
            match = filteredMatches[indexPath.row]
        }else{
            match = matches[indexPath.row]
        }
        
        var displayedTime = ""
        if let time = match.time {
            if let readableTime = timeFromNSDate(time) {
                displayedTime = readableTime
            }
        }else{
            displayedTime = "N/A"
        }
        cell.matchNum.text = "Match " + String(match.number)
        cell.matchTime.text = displayedTime
        cell.redTeam1.text = match.redTeams[0]
        cell.redTeam2.text = match.redTeams[1]
        cell.redTeam3.text = match.redTeams[2]
        cell.blueTeam1.text = match.blueTeams[0]
        cell.blueTeam2.text = match.blueTeams[1]
        cell.blueTeam3.text = match.blueTeams[2]
        
        cell.backgroundColor = UIColorFromHex("F3F3F3")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showMatch", sender: indexPath)
        matchesTable.deselectRow(at: indexPath, animated: true)
        self.searchController.searchBar.isHidden = true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredMatches = matches.filter { match in
            let containsRed1 = String(match.redTeams[0]).lowercased().contains(searchText.lowercased())
            let containsRed2 = String(match.redTeams[1]).lowercased().contains(searchText.lowercased())
            let containsRed3 = String(match.redTeams[2]).lowercased().contains(searchText.lowercased())
            let containsBlue1 = String(match.blueTeams[0]).lowercased().contains(searchText.lowercased())
            let containsBlue2 = String(match.blueTeams[1]).lowercased().contains(searchText.lowercased())
            let containsBlue3 = String(match.blueTeams[2]).lowercased().contains(searchText.lowercased())
            return containsRed1 || containsRed2 || containsRed3 || containsBlue1 || containsBlue2 || containsBlue3
        }
        
        matchesTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showMatch") {
            let match: Match
            if searchController.isActive && searchController.searchBar.text != "" {
                match = filteredMatches[(sender! as AnyObject).row]
            }else{
                match = matches[(sender! as AnyObject).row]
            }
            let matchVC = segue.destination as! MatchVC
            matchVC.matchNumber = match.number
            matchVC.redTeams = match.redTeams
            matchVC.blueTeams = match.blueTeams
        }
    }
    
}

//MARK: - Extensions

extension MatchesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
