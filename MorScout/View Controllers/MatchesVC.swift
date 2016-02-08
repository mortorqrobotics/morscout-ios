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
    
}