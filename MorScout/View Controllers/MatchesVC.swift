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
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var matches = [Match]()
    var filteredMatches = [Match]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        matchesTable.tableHeaderView = searchController.searchBar
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search Teams in Matches"
        
        checkConnectionAndSync()
        
        if let matchesData = storage.objectForKey("matches") {
            let cachedMatches = NSKeyedUnarchiver.unarchiveObjectWithData(matchesData as! NSData) as? [Match]
            
            if cachedMatches!.count == 0 {
                alert(title: "No Data Found", message: "In order to load the data, you need to have connected to the internet at least once.", buttonText: "OK", viewController: self)
            }else{
                self.matches = cachedMatches!
            }
        }else{
            alert(title: "No Data Found", message: "In order to load the data, you need to have connected to the internet at least once.", buttonText: "OK", viewController: self)
        }

        if Reachability.isConnectedToNetwork() {
            getMatches()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.searchController.searchBar.hidden = false
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
                self.matches = []
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
                        if let match_time = Double(match_time) {
                            self.matches.append(Match(number: Int(match_num)!, time: NSDate(timeIntervalSince1970: match_time), redTeams: redTeams, blueTeams: blueTeams))
                        }else{
                            self.matches.append(Match(number: Int(match_num)!, time: nil, redTeams: redTeams, blueTeams: blueTeams))
                        }
                        
                        
                        
                    }
                    
                }
                
                self.matches.sortInPlace { $0.time!.compare($1.time!) == .OrderedAscending }
                
                let matchesData = NSKeyedArchiver.archivedDataWithRootObject(self.matches)
                storage.setObject(matchesData, forKey: "matches")
                
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
        if searchController.active && searchController.searchBar.text != "" {
            return filteredMatches.count
        }else{
            return matches.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = matchesTable.dequeueReusableCellWithIdentifier("matchCell") as! MatchCell
        
        let match: Match
        if searchController.active && searchController.searchBar.text != "" {
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showMatch", sender: indexPath)
        matchesTable.deselectRowAtIndexPath(indexPath, animated: true)
        self.searchController.searchBar.hidden = true
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredMatches = matches.filter { match in
            let containsRed1 = String(match.redTeams[0]).lowercaseString.containsString(searchText.lowercaseString)
            let containsRed2 = String(match.redTeams[1]).lowercaseString.containsString(searchText.lowercaseString)
            let containsRed3 = String(match.redTeams[2]).lowercaseString.containsString(searchText.lowercaseString)
            let containsBlue1 = String(match.blueTeams[0]).lowercaseString.containsString(searchText.lowercaseString)
            let containsBlue2 = String(match.blueTeams[1]).lowercaseString.containsString(searchText.lowercaseString)
            let containsBlue3 = String(match.blueTeams[2]).lowercaseString.containsString(searchText.lowercaseString)
            return containsRed1 || containsRed2 || containsRed3 || containsBlue1 || containsBlue2 || containsBlue3
        }
        
        matchesTable.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showMatch") {
            if let matchesData = storage.objectForKey("matches") {
                let cachedMatches = NSKeyedUnarchiver.unarchiveObjectWithData(matchesData as! NSData) as? [Match]
                let matchVC = segue.destinationViewController as! MatchVC
                matchVC.matchNumber = cachedMatches![sender!.row].number
                matchVC.redTeams = cachedMatches![sender!.row].redTeams
                matchVC.blueTeams = cachedMatches![sender!.row].blueTeams
            }
        }
    }
    
}

extension MatchesVC: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}