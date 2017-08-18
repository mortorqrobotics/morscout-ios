//
//  MenuVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/16/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class MenuVC: UITableViewController {
    
    @IBOutlet weak var menuName: UILabel!
    @IBOutlet weak var menuProfilePic: UIImageView!
    @IBOutlet var menuTable: UITableView!
    
    @IBOutlet weak var viewProfileCell: UITableViewCell!
    @IBOutlet weak var homeCell: UITableViewCell!
    @IBOutlet weak var matchesCell: UITableViewCell!
    @IBOutlet weak var teamsCell: UITableViewCell!
    @IBOutlet weak var settingsCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    override func viewDidLoad() {
        
        //for weird color bug on iPad
        viewProfileCell.backgroundColor = UIColorFromHex("FFC547")
        homeCell.backgroundColor = UIColorFromHex("FFC547")
        matchesCell.backgroundColor = UIColorFromHex("FFC547")
        teamsCell.backgroundColor = UIColorFromHex("FFC547")
        settingsCell.backgroundColor = UIColorFromHex("FFC547")
        logoutCell.backgroundColor = UIColorFromHex("FFC547")
        
        if let firstName = storage.string(forKey: "firstname"), let lastName = storage.string(forKey: "lastname") {
            DispatchQueue.main.async(execute: {
                self.menuName.text = "\(firstName) \(lastName)"
                self.menuProfilePic.layer.cornerRadius = 17
                self.menuProfilePic.clipsToBounds = true
            })
        }
        if let savedProfPicPath = storage.string(forKey: "profpicpath") {
            menuProfilePic.kf.setImage(with: URL(string: "http://www.morteam.com" + savedProfPicPath + "-60")!, options: [.requestModifier(modifier)])
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 5 {
            logout()
        }
    }
    
    func logout() {
        httpRequest(morTeamURL + "/logout", type: "POST"){ responseText in

            for key in storage.dictionaryRepresentation().keys {
                UserDefaults.standard.removeObject(forKey: key)
            }
            self.goTo(viewController: "login")

        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .default
        let bgColorView: UIView = UIView()
        bgColorView.backgroundColor = UIColorFromHex("FFA500")
        cell.selectedBackgroundView = bgColorView
    }
}
