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
    @IBOutlet weak var infoBar: UIView!
    
    var regionals = [Regional]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        checkConnectionAndSync()
        handleEditing(storage.stringForKey("_id")!)
        
//        if let savedReports = storage.arrayForKey("savedReports") {
//            print(savedReports)
//        }else{
//            print("no saved reports")
//        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setup() {
        
        regionalPicker.dataSource = self
        regionalPicker.delegate = self
        regionalYear.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        if Reachability.isConnectedToNetwork() {
            getCurrentRegionalInfo()
            getShareDataStatus()
        }else{
            alert(title: "No Connection", message: "Cannot edit settings without internet connection", buttonText: "OK", viewController: self)
        }
        
        
        self.regionalPicker.userInteractionEnabled = false
        self.regionalYear.userInteractionEnabled = false
        self.shareData.enabled = false

        let toolbarAndButton = createToolbar()
        let doneButton = toolbarAndButton.1
        let toolbar = toolbarAndButton.0
        doneButton.textField = self.regionalYear
        self.regionalYear.inputAccessoryView = toolbar
        
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
            let currentRegionalName = String(regionalInfo["short_name"])
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
                let isPrivate: Bool
                if responseText == "true" {
                    isPrivate = true
                }else{
                    isPrivate = false
                }
                dispatch_async(dispatch_get_main_queue(),{
                    self.shareData.setOn(!isPrivate, animated: false)
                })
                self.shareData.addTarget(self, action: Selector("shareDataStateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
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
                    let name = String(subJson["short_name"])
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
    
    func handleEditing(_id: String) {
        httpRequest(morTeamURL+"/f/getUser", type: "POST", data: ["_id": _id]) {responseText in
            if responseText != "fail" {
                let user = parseJSON(responseText)
                
                if String(user["current_team"]["position"]) != "member" || Bool(user["current_team"]["scoutCaptain"]) == true {
                    dispatch_async(dispatch_get_main_queue(),{
                        self.regionalPicker.userInteractionEnabled = true
                        self.regionalYear.userInteractionEnabled = true
                        self.shareData.enabled = true
                    })
                }
            }
        }
    }
    
    func createToolbar() -> (UIToolbar, DoneButton) {
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let doneButton = DoneButton(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "clickedDoneButton:")
        toolBar.setItems([flexSpace, doneButton], animated: true)
        return (toolBar, doneButton)
    }
    
    func clickedDoneButton(sender: UIBarButtonItem) {
        let sender = sender as! DoneButton
        
        if let textField = sender.textField {
            textField.resignFirstResponder()
        }
        
        if let textView = sender.textView {
            textView.resignFirstResponder()
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