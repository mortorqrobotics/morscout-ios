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
    @IBOutlet weak var shareData: UISwitch!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var regionals = [Regional]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        getCurrentRegionalInfo()
        getShareDataStatus()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setup() {
        regionalPicker.dataSource = self
        regionalPicker.delegate = self
        regionalYear.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        shareData.addTarget(self, action: Selector("shareDataStateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func getCurrentRegionalInfo() {
        httpRequest(baseURL+"/getCurrentRegionalInfo", type: "POST"){
            responseText in
            
            let regionalInfo = parseJSON(responseText)
            let currentRegionalYear = String(regionalInfo["year"])
            let currentRegionalName = String(regionalInfo["name"])
            if (!regionalInfo["Errors"]){
                dispatch_async(dispatch_get_main_queue(),{
                    self.regionalYear.text = currentRegionalYear
                    self.loadRegionalsForYear(currentRegionalYear) {
                        for(var i = 0; i < self.regionals.count; i++) {
                            if self.regionals[i].name == currentRegionalName {
                                self.regionalPicker.selectRow(i, inComponent: 0, animated: false)
                                //self.chooseRegional(self.regionals[i].key)
                                let selectedRow = self.regionalPicker.selectedRowInComponent(0)
                                if selectedRow < self.regionals.count  {
                                    self.chooseRegional(self.regionals[selectedRow].key)
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    func getShareDataStatus() {
        httpRequest(baseURL+"/getDataStatus", type: "POST"){
            responseText in
            
            if responseText != "fail" {
                let isPublic: Bool
                if responseText == "true" {
                    isPublic = false
                }else{
                    isPublic = true
                }
                self.shareData.setOn(isPublic, animated: false)
            }
        }
    }
    
    func loadRegionalsForYear(year: String, cb: (() -> ())?) {
        httpRequest(baseURL+"/getRegionalsForTeam", type: "POST", data:[
            "year": year
        ]){ responseText in
            if responseText != "fail" {
                let regionals = parseJSON(responseText)
                if regionals.count == 0 {
                    alert(title: "Invalid Year", message: "No competitions were found for the selected year", buttonText: "OK", viewController: self)
                }
                self.regionals = []
                for (_, subJson):(String, JSON) in regionals {
                    let key = String(subJson["key"])
                    let name = String(subJson["name"])
                    let year = String(subJson["year"])
                    let regional = Regional(key: key, name: name, year: year)
                    self.regionals.append(regional)
                }
                dispatch_async(dispatch_get_main_queue(),{
                    self.regionalPicker.reloadAllComponents()
                    cb?()
                })
            }
        }
    }
    
    func chooseRegional(key: String) {
        httpRequest(baseURL+"/chooseCurrentRegional", type: "POST", data: [
            "eventCode": key
        ]) { responseText in
            if responseText == "success" {
                storage.setValue(key, forKey: "currentRegional")
                print("set regional to \(key)")
            }
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        if regionalYear.text!.characters.count == 4 {
            loadRegionalsForYear(regionalYear.text!){
                let selectedRow = self.regionalPicker.selectedRowInComponent(0)
                if selectedRow < self.regionals.count  {
                    self.chooseRegional(self.regionals[selectedRow].key)
                }
            }
        }
    }
    
    func shareDataStateChanged(switchState: UISwitch) {
        if switchState.on {
            httpRequest(baseURL+"/setDataStatus", type: "POST", data: [
                "status": "public"
            ]){ responseText in
                if responseText == "fail" {
                    self.shareData.setOn(false, animated: true)
                    alert(title: "failed to switch", message: "Oops, there was an internal error when switching the status", buttonText: "OK", viewController: self)
                }
            }
        } else {
            httpRequest(baseURL+"/setDataStatus", type: "POST", data: [
                "status": "private"
            ]){ responseText in
                if responseText == "fail" {
                    self.shareData.setOn(true, animated: true)
                    alert(title: "failed to switch", message: "Oops, there was an internal error when switching the status", buttonText: "OK", viewController: self)
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
        if row < regionals.count && row >= 0 {
            self.chooseRegional(regionals[row].key)
        }
        
    }
    
}