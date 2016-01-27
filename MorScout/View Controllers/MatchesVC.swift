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
    @IBOutlet var matchesTableView: UITableView!
    
    var matches = [Match]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        matchesTableView.delegate = self
        matchesTableView.dataSource = self

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
                    print(subJson)
                }
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
        let index = indexPath.row
        let cell = matchesTableView.dequeueReusableCellWithIdentifier("matchCell", forIndexPath: indexPath) as! MatchCell
        cell.label.text = "Match \(matches[index].number)"
        return cell
    }
    
}