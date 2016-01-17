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
    
    @IBAction func logoutButton(sender: UIBarButtonItem) {
        httpRequest(baseURL+"/logout", type: "POST"){ responseText in
            
            if responseText == "success" {
                for key in storage.dictionaryRepresentation().keys {
                    NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
                }
                dispatch_async(dispatch_get_main_queue(),{
                    let vc : UIViewController! = self.storyboard!.instantiateViewControllerWithIdentifier("login")
                    self.presentViewController(vc, animated: true, completion: nil)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(),{
                    let alert = UIAlertController(title: "Oops", message: responseText, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
