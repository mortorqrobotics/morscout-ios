//
//  ProfileVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/7/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class ProfileVC: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var assigmentsScrollView: UIScrollView!
    
    @IBOutlet weak var matchReports: UILabel!
    @IBOutlet weak var pitReports: UILabel!
    @IBOutlet weak var teamsScouted: UILabel!
    @IBOutlet weak var assignmentsComplete: UILabel!
    @IBOutlet weak var assignmentsIncomplete: UILabel!
    @IBOutlet weak var assignmentCompletion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
}