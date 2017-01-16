//
//  SettingsVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/17/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

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
        handleEditing(storage.string(forKey: "_id")!)
        
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
        regionalYear.addTarget(self, action: #selector(SettingsVC.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        if Reachability.isConnectedToNetwork() {
            getCurrentRegionalInfo()
            getShareDataStatus()
        }else{
            alert(title: "No Connection", message: "Cannot edit settings without internet connection", buttonText: "OK", viewController: self)
        }
        
        
        self.regionalPicker.isUserInteractionEnabled = false
        self.regionalYear.isUserInteractionEnabled = false
        self.shareData.isEnabled = false

        let toolbarAndButton = createToolbar()
        let doneButton = toolbarAndButton.1
        let toolbar = toolbarAndButton.0
        doneButton.textField = self.regionalYear
        self.regionalYear.inputAccessoryView = toolbar
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func getCurrentRegionalInfo() {
        httpRequest(baseURL+"/getCurrentRegionalInfo", type: "POST"){
            responseText in
            
            let regionalInfo = parseJSON(responseText)
            let currentRegionalYear = regionalInfo["year"].stringValue
            let currentRegionalName = regionalInfo["short_name"].stringValue
            if !regionalInfo["Errors"].exists() {
                DispatchQueue.main.async(execute: {
                    self.regionalYear.text = currentRegionalYear
                    self.loadRegionalsForYear(currentRegionalYear) {
                        for i in 0..<self.regionals.count {
                            if self.regionals[i].name == currentRegionalName {
                                self.regionalPicker.selectRow(i, inComponent: 0, animated: false)
                                //self.chooseRegional(self.regionals[i].key)
                                let selectedRow = self.regionalPicker.selectedRow(inComponent: 0)
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
                DispatchQueue.main.async(execute: {
                    self.shareData.setOn(!isPrivate, animated: false)
                })
                self.shareData.addTarget(self, action: #selector(SettingsVC.shareDataStateChanged(_:)), for: UIControlEvents.valueChanged)
            }
        }
    }
    
    func loadRegionalsForYear(_ year: String, cb: (() -> ())?) {
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
                    let key = subJson["key"].stringValue
                    let name = subJson["short_name"].stringValue
                    let year = subJson["year"].stringValue
                    let regional = Regional(key: key, name: name, year: year)
                    self.regionals.append(regional)
                }
                DispatchQueue.main.async(execute: {
                    self.regionalPicker.reloadAllComponents()
                    cb?()
                })
            }
        }
    }
    
    func chooseRegional(_ key: String) {
        httpRequest(baseURL+"/chooseCurrentRegional", type: "POST", data: [
            "eventCode": key
        ]) { responseText in
            if responseText == "success" {
                storage.setValue(key, forKey: "currentRegional")
                print("set regional to \(key)")
            }
        }
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if regionalYear.text!.characters.count == 4 {
            loadRegionalsForYear(regionalYear.text!){
                let selectedRow = self.regionalPicker.selectedRow(inComponent: 0)
                if selectedRow < self.regionals.count  {
                    self.chooseRegional(self.regionals[selectedRow].key)
                }
            }
        }
    }
    
    func shareDataStateChanged(_ switchState: UISwitch) {
        if switchState.isOn {
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
    
    func handleEditing(_ _id: String) {
        httpRequest(morTeamURL+"/f/getUser", type: "POST", data: ["_id": _id]) {responseText in
            if responseText != "fail" {
                let user = parseJSON(responseText)
                
                if user["current_team"]["position"].stringValue != "member" || user["current_team"]["scoutCaptain"].boolValue == true {
                    DispatchQueue.main.async(execute: {
                        self.regionalPicker.isUserInteractionEnabled = true
                        self.regionalYear.isUserInteractionEnabled = true
                        self.shareData.isEnabled = true
                    })
                }
            }
        }
    }
    
    func createToolbar() -> (UIToolbar, DoneButton) {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = DoneButton(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SettingsVC.clickedDoneButton(_:)))
        toolBar.setItems([flexSpace, doneButton], animated: true)
        return (toolBar, doneButton)
    }
    
    func clickedDoneButton(_ sender: UIBarButtonItem) {
        let sender = sender as! DoneButton
        
        if let textField = sender.textField {
            textField.resignFirstResponder()
        }
        
        if let textView = sender.textView {
            textView.resignFirstResponder()
        }
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return regionals.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return regionals[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < regionals.count && row >= 0 {
            self.chooseRegional(regionals[row].key)
        }
        
    }
    
}
