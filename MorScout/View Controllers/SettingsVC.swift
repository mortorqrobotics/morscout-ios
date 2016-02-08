//
//  SettingsVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/17/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC: UITableViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    
    @IBOutlet weak var regionalPicker: UIPickerView!
    @IBOutlet weak var regionalYear: UITextField!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var regionals = ["Ventura Regional", "Las Vegas Regional"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        regionalPicker.dataSource = self
        regionalPicker.delegate = self
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
 
        regionalYear.text = "\(components.year)"
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return regionals.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return regionals[row]
    }
    
//    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//       
//    }
    
}