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
    var regionals = [Regional]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        let currentYear = getAndSetCurrentYear()
        loadRegionalsForYear(currentYear)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setup() {
        regionalPicker.dataSource = self
        regionalPicker.delegate = self
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    func getAndSetCurrentYear() -> String {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        regionalYear.text = "\(components.year)"
        storage.setValue("\(components.year)", forKey: "currentRegionalYear")
        return String(components.year)
    }
    
    func loadRegionalsForYear(year: String) {
        httpRequest(baseURL+"/getRegionalsForTeam", type: "POST", data:[
            "year": year
            ]){ responseText in
                if responseText != "fail" {
                    let regionals = parseJSON(responseText)
                    for (i, subJson):(String, JSON) in regionals {
                        let key = String(subJson["name"])
                        let name = String(subJson["name"])
                        let year = String(subJson["name"])
                        let regional = Regional(key: key, name: name, year: year)
                        self.regionals.append(regional)
                        if Int(i) == 0 {
                            //storage.setValue(regional.key, forKey: "currentRegional")
                            self.chooseRegional(regional.key)
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(),{
                        self.regionalPicker.reloadAllComponents()
                    })
                    
                }
        }
    }
    
    func chooseRegional(key: String) {
        if let eventCode = storage.stringForKey("currentRegional") {
            httpRequest(baseURL+"/chooseCurrentRegional", type: "POST", data: [
                "eventCode": eventCode
            ]) { responseText in
                if responseText == "success" {
                    storage.setValue(key, forKey: "currentRegional")
                }
            }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return regionals.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return regionals[row].name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.chooseRegional(regionals[row].key)
    }
    
}