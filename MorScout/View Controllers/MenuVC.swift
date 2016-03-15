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
    
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var menuName: UILabel!
    @IBOutlet weak var menuProfilePic: UIImageView!
    @IBOutlet var menuTable: UITableView!
    @IBOutlet weak var settingsCell: UITableViewCell!
    
    override func viewDidLoad() {
        
        if let firstName = storage.stringForKey("firstname"), lastName = storage.stringForKey("lastname") {
            dispatch_async(dispatch_get_main_queue(),{
                self.menuName.text = "\(firstName) \(lastName)"
                self.menuProfilePic.layer.cornerRadius = 17
                self.menuProfilePic.clipsToBounds = true
            })
        }
        
        menuProfilePic.kf_setImageWithURL(NSURL(string: "http://www.morteam.com/pp/" + storage.stringForKey("username")! + "-60")!)
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 5 {
            logout()
        }
    }
    
    func logout() {
        httpRequest(morTeamURL+"/f/logout", type: "POST"){ responseText in
            
//            if responseText == "success" {
                for key in storage.dictionaryRepresentation().keys {
                    NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
                }
                dispatch_async(dispatch_get_main_queue(),{
                    let vc : UIViewController! = self.storyboard!.instantiateViewControllerWithIdentifier("login")
                    self.presentViewController(vc, animated: true, completion: nil)
                })
//            } else {
//                dispatch_async(dispatch_get_main_queue(),{
//                    let alert = UIAlertController(title: "Oops", message: responseText, preferredStyle: UIAlertControllerStyle.Alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                    self.presentViewController(alert, animated: true, completion: nil)
//                })
//            }
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.selectionStyle = .Default
        let bgColorView: UIView = UIView()
        bgColorView.backgroundColor = UIColorFromHex("FFA500")
        cell.selectedBackgroundView = bgColorView
    }
}