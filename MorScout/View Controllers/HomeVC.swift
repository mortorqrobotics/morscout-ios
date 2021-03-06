//
//  HomeVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/8/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var welcomeMessage: UILabel!
    
    let welcomeMessages = [
        "Welcome to MorScout!", "OurScout is MorScout than YourScout",
        "Made With Fifty Shades of Orange", "LessWork, MorScout",
        "MorPower, MorTeamwork, MorIngenuity, MorScout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkConnectionAndSync()
        setupMenu(menuButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // randomize welcome message
        let welcomeMessagesLength = UInt32(welcomeMessages.count)
        let randomInt = Int(arc4random_uniform(welcomeMessagesLength))
        welcomeMessage.text = welcomeMessages[randomInt]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
