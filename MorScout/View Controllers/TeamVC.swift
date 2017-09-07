//
//  TeamVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/3/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import SwiftyJSON

class TeamVC: UIViewController {
    
    var teamNumber = 0
    var teamName = ""
    
    @IBOutlet weak var teamTitle: UINavigationItem!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamWebLink: UITextView!
    @IBOutlet weak var teamLocation: UILabel!
    @IBOutlet weak var modeTabs: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!

    /// This view "contains" all of the elements in
    /// the scout form or view form and changes in size
    /// based on the amount of information needed to be
    /// displayed at the current time.
    /// This UIView element will be referred to as
    /// the "container" in most documentation in this file.
    var container = UIView()
    var scoutFormHeight: CGFloat = 5
    var viewFormHeight: CGFloat = 5
    
    var picker: DropdownPicker = DropdownPicker()
    /// The array of options for each DropdownPicker
    /// with a String name.
    var pickerLists = [String: Array<String>]()
    
    var dataPoints = [DataPoint]()
    
    var scoutFormIsVisible = false
    var viewFormIsVisible = false
    
    var scoutFormDataIsLoaded = false
    var viewFormDataIsLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkConnectionAndSync()
        
        teamTitle.title = "Team \(teamNumber)"
        teamNameLabel.text = teamName
        
        if Reachability.isConnectedToNetwork() {
            httpRequest(baseURL + "/getTeamInfo", type: "POST", data: [
                "teamNumber": String(teamNumber)
            ]){ responseText in
                let teamInfo = parseJSON(responseText)
                DispatchQueue.main.async(execute: {
                    self.teamWebLink.text = teamInfo["website"].stringValue
                    self.teamLocation.text = teamInfo["location"].stringValue
                })
            }
        }

        modeTabs.selectedSegmentIndex = -1
        
        picker.delegate = self
        picker.dataSource = self
        
        self.scrollView.addSubview(self.container)
        
        if Reachability.isConnectedToNetwork() {
            getCurrentRegionalKey()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changeModeTabs(_ sender: UISegmentedControl) {
        switch modeTabs.selectedSegmentIndex {
        case 0:
            hideViewFormElements()
            showScoutForm()
        case 1:
            hideScoutFormElements()
            showViewForm()
        default:
            break
        }
    }
    
    func showScoutForm() {
        if scoutFormDataIsLoaded {
            if !scoutFormIsVisible {
                for view in container.subviews {
                    if view.tag == 0 {
                        view.isHidden = false
                    }
                }
                resizeContainerHeight(self.scoutFormHeight)
            }
        } else {
            if Reachability.isConnectedToNetwork() {
                loadScoutForm()
            } else {
                if let dataPointsData = storage.object(forKey: "teamDataPoints") {
                    let cachedDataPoints = NSKeyedUnarchiver.unarchiveObject(with: dataPointsData as! Data) as? [DataPoint]
                    
                    if cachedDataPoints!.count == 0 {
                        alert(
                            title: "No Data Found",
                            message: "In order to load the data, you need to have connected to the internet at least once.",
                            buttonText: "OK", viewController: self)
                    } else {
                        retrieveScoutFormFromCache()
                    }
                } else {
                    alert(
                        title: "No Data Found",
                        message: "In order to load the data, you need to have connected to the internet at least once.",
                        buttonText: "OK", viewController: self)
                }
            }
        }
        self.scoutFormIsVisible = true
    }
    
    func loadScoutForm() {
        httpRequest(baseURL + "/getScoutForm", type: "POST", data: [
            "context": "pit"
        ]) { responseText in
            let formData = parseJSON(responseText)
            DispatchQueue.main.async(execute: {
                
                for(i, subJson):(String, JSON) in formData {
                    let type = subJson["type"].stringValue
                    if type == "label" {
                        self.dataPoints.append(Label(json: subJson))
                    } else if type == "text" {
                        self.dataPoints.append(TextBox(json: subJson))
                    } else if type == "dropdown" || type == "radio" {
                        self.dataPoints.append(Dropdown(json: subJson))
                    } else if type == "number" {
                        self.dataPoints.append(NumberBox(json: subJson))
                    } else if type == "checkbox" {
                        self.dataPoints.append(Checkbox(json: subJson))
                    }
                    self.createDataPoint(self.dataPoints[Int(i)!])
                }
                
                self.createSubmitButton()
                
                let dataPointsData = NSKeyedArchiver.archivedData(withRootObject: self.dataPoints)
                storage.set(dataPointsData, forKey: "teamDataPoints")
                
                self.scoutFormDataIsLoaded = true
                
                self.resizeContainerHeight(self.scoutFormHeight)
                
            })
        }
    }
    
    func retrieveScoutFormFromCache() {
        if let dataPointsData = storage.object(forKey: "teamDataPoints") {
            let cachedDataPoints = NSKeyedUnarchiver.unarchiveObject(with: dataPointsData as! Data) as? [DataPoint]
            
            for cachedDataPoint in cachedDataPoints! {
                self.createDataPoint(cachedDataPoint)
            }
            
            createSubmitButton()
            
            scoutFormDataIsLoaded = true
            
            self.resizeContainerHeight(self.scoutFormHeight)

        }
    }
    
    func hideScoutFormElements() {
        for view in self.container.subviews {
            if view.tag == 0 {
                view.isHidden = true
            }
        }
        scoutFormIsVisible = false
    }
    
    func showViewForm() {
        if viewFormDataIsLoaded {
            if !viewFormIsVisible {
                for view in container.subviews {
                    if view.tag == teamNumber {
                        view.isHidden = false
                    }
                }
            }
            self.resizeContainerHeight(self.viewFormHeight)
        } else {
            if Reachability.isConnectedToNetwork() {
                loadViewForm()
            } else {
                alert(
                    title: "Cannot load scouted reports",
                    message: "Unfortunately you need to be connected to the internet to view previous reports",
                    buttonText: "OK", viewController: self)
            }
        }
        self.viewFormIsVisible = true
        
    }
    
    func loadViewForm() {
        httpRequest(baseURL + "/getTeamReports", type: "POST", data: [
            "reportContext": "pit",
            "teamNumber": String(teamNumber)
        ]) { responseText in
            
            let data = parseJSON(responseText)
            
            self.viewFormDataIsLoaded = true
            
            DispatchQueue.main.async(execute: {
                
                self.viewFormHeight = 5
                
                if data["yourTeam"].count == 0 && data["otherTeams"].count == 0 {
                    self.viewFormHeight += 25
                    let label = UILabel(frame: CGRect(x: 10, y: self.viewFormHeight, width: self.view.frame.width - 20, height: 21))
                    label.text = "No Reports"
                    label.font = UIFont(name: "Helvetica-Light", size: 22.0)
                    label.textAlignment = .center
                    label.tag = self.teamNumber
                    self.container.addSubview(label)
                    self.viewFormHeight += label.frame.height + 5
                }
                
                if data["yourTeam"].count != 0 {
                    let label = UILabel(frame: CGRect(x: 10, y: self.viewFormHeight, width: self.view.frame.width - 20, height: 21))
                    label.text = "Your Team"
                    label.font = UIFont(name: "Helvetica-Light", size: 22.0)
                    label.textAlignment = .center
                    label.tag = self.teamNumber
                    self.container.addSubview(label)
                    self.viewFormHeight += label.frame.height + 5
                    
                    let line = UIView(frame: CGRect(x: 40, y: self.viewFormHeight, width: self.view.frame.width-80, height: 1))
                    line.backgroundColor = UIColor.lightGray
                    line.tag = self.teamNumber
                    self.container.addSubview(line)
                    self.viewFormHeight += line.frame.height + 10
                    
                    for(i, subJson):(String, JSON) in data["yourTeam"] {
                        let reportNumber = Int(i)!+1
                        let label = UILabel(frame: CGRect(x: 10, y: self.viewFormHeight, width: self.view.frame.width - 20, height: 21))
                        label.text = "Report \(reportNumber)"
                        label.font = UIFont(name: "Helvetica-Light", size: 21.0)
                        label.textAlignment = .center
                        label.tag = self.teamNumber
                        self.container.addSubview(label)
                        self.viewFormHeight += label.frame.height + 5
                        
                        let line = UIView(frame: CGRect(x: 60, y: self.viewFormHeight, width: self.view.frame.width-120, height: 1))
                        line.backgroundColor = UIColor.lightGray
                        line.tag = self.teamNumber
                        self.container.addSubview(line)
                        self.viewFormHeight += line.frame.height + 10
                        
                        for(_, subJson):(String, JSON) in subJson["data"] {
                            if subJson["value"].stringValue == "null" {
                                let label = UILabel(frame: CGRect(x: 10, y: self.viewFormHeight, width: self.view.frame.width - 20, height: 21))
                                label.text = subJson["name"].stringValue
                                label.font = UIFont(name: "Helvetica-Light", size: 20.0)
                                label.textAlignment = .center
                                label.tag = self.teamNumber
                                self.container.addSubview(label)
                                self.viewFormHeight += label.frame.height + 5
                                
                                let line = UIView(frame: CGRect(x: 80, y: self.viewFormHeight, width: self.view.frame.width-160, height: 1))
                                line.backgroundColor = UIColor.lightGray
                                line.tag = self.teamNumber
                                self.container.addSubview(line)
                                self.viewFormHeight += line.frame.height + 10
                            } else {
                                let key = UILabel(frame: CGRect(x: 10, y: self.viewFormHeight, width: self.view.frame.width - 160, height: 21))
                                key.text = subJson["name"].stringValue
                                key.tag = self.teamNumber
                                self.container.addSubview(key)
                                var height = heightForView(subJson["value"].stringValue, width: 140)
                                if height == 0 {
                                    height = 21
                                }
                                let value = UILabel(frame: CGRect(x: self.view.frame.width-150, y: self.viewFormHeight, width: 140 , height: height))
                                value.numberOfLines = 0
                                if subJson["value"].stringValue == "" {
                                    value.text = "N/A"
                                } else {
                                    value.text = subJson["value"].stringValue
                                }

                                value.tag = self.teamNumber
                                self.container.addSubview(value)
                                
                                self.viewFormHeight += value.frame.height + 5
                            }
                        }
                    }
                }
                
                if data["otherTeams"].count != 0 {
                    
                    let label = UILabel(frame: CGRect(x: 10, y: self.viewFormHeight, width: self.view.frame.width - 20, height: 21))
                    label.text = "Other Teams"
                    label.font = UIFont(name: "Helvetica-Light", size: 22.0)
                    label.textAlignment = .center
                    label.tag = self.teamNumber
                    self.container.addSubview(label)
                    self.viewFormHeight += label.frame.height + 5
                    
                    let line = UIView(frame: CGRect(x: 40, y: self.viewFormHeight, width: self.view.frame.width-80, height: 1))
                    line.backgroundColor = UIColor.lightGray
                    line.tag = self.teamNumber
                    self.container.addSubview(line)
                    self.viewFormHeight += line.frame.height + 10
                    
                    
                    for(i, subJson):(String, JSON) in data["otherTeams"] {
                        let reportNumber = Int(i)!+1
                        let label = UILabel(frame: CGRect(x: 10, y: self.viewFormHeight, width: self.view.frame.width - 20, height: 21))
                        label.text = "Report \(reportNumber)"
                        label.font = UIFont(name: "Helvetica-Light", size: 21.0)
                        label.textAlignment = .center
                        label.tag = self.teamNumber
                        self.container.addSubview(label)
                        self.viewFormHeight += label.frame.height + 5
                        
                        let line = UIView(frame: CGRect(x: 60, y: self.viewFormHeight, width: self.view.frame.width-120, height: 1))
                        line.backgroundColor = UIColor.lightGray
                        line.tag = self.teamNumber
                        self.container.addSubview(line)
                        self.viewFormHeight += line.frame.height + 10
                        
                        for(_, subJson):(String, JSON) in subJson["data"] {
                            if subJson["value"].stringValue == "null" {
                                let label = UILabel(frame: CGRect(x: 10, y: self.viewFormHeight, width: self.view.frame.width - 20, height: 21))
                                label.text = subJson["name"].stringValue
                                label.font = UIFont(name: "Helvetica-Light", size: 20.0)
                                label.textAlignment = .center
                                label.tag = self.teamNumber
                                self.container.addSubview(label)
                                self.viewFormHeight += label.frame.height + 5
                                
                                let line = UIView(frame: CGRect(x: 80, y: self.viewFormHeight, width: self.view.frame.width-160, height: 1))
                                line.backgroundColor = UIColor.lightGray
                                line.tag = self.teamNumber
                                self.container.addSubview(line)
                                self.viewFormHeight += line.frame.height + 10
                            } else {
                                let key = UILabel(frame: CGRect(x: 10, y: self.viewFormHeight, width: self.view.frame.width - 160, height: 21))
                                key.text = subJson["name"].stringValue
                                key.tag = self.teamNumber
                                self.container.addSubview(key)
                                var height = heightForView(subJson["value"].stringValue, width: 140)
                                if height == 0 {
                                    height = 21
                                }
                                let value = UILabel(frame: CGRect(x: self.view.frame.width-150, y: self.viewFormHeight, width: 140 , height: height))
                                value.numberOfLines = 0
                                if subJson["value"].stringValue == "" {
                                    value.text = "N/A"
                                } else {
                                    value.text = subJson["value"].stringValue
                                }

                                value.tag = self.teamNumber
                                self.container.addSubview(value)
                                
                                self.viewFormHeight += value.frame.height + 5
                            }
                        }
                    }
                }
                
                self.resizeContainerHeight(self.viewFormHeight)
                
            })
        }
    }

    func hideViewFormElements() {
        for view in self.container.subviews {
            if view.tag != 0 {
                view.isHidden = true
            }
        }
        viewFormIsVisible = false
    }
    
    func createDataPoint(_ dataPoint: DataPoint) {
        
        //the tags for scout form elements are being set to 0
        
        let type = String(describing: Mirror(reflecting: dataPoint).subjectType)
        
        switch type {
        case "Label":
            let dataPoint = dataPoint as! Label
            
            let label = UILabel(frame: CGRect(x: 10, y: self.scoutFormHeight, width: self.view.frame.width-20, height: 26))
            label.text = dataPoint.name
            label.font = UIFont(name: "Helvetica-Light", size: 22.0)
            label.textAlignment = .center
            label.tag = 0
            self.container.addSubview(label)
            self.scoutFormHeight += label.frame.height + 5
            
            let line = UIView(frame: CGRect(x: 80, y: self.scoutFormHeight, width: self.view.frame.width-160, height: 1))
            line.backgroundColor = UIColor.lightGray
            line.tag = 0
            self.container.addSubview(line)
            self.scoutFormHeight += line.frame.height + 10
            
        case "TextBox":
            let dataPoint = dataPoint as! TextBox
            
            let label = UILabel(frame: CGRect(x: 10, y: self.scoutFormHeight, width: self.view.frame.width-20, height: 21))
            label.text = dataPoint.name
            label.font = UIFont(name: "Helvetica-Light", size: 17.0)
            label.textColor = UIColor.black
            label.tag = 0
            self.container.addSubview(label)
            self.scoutFormHeight += label.frame.height + 5
            
            let textbox = UITextView(frame: CGRect(x: 10, y: self.scoutFormHeight, width: self.view.frame.width-20, height: 90))
            textbox.font = UIFont.systemFont(ofSize: 15)
            textbox.autocorrectionType = UITextAutocorrectionType.no
            textbox.keyboardType = UIKeyboardType.default
            textbox.returnKeyType = UIReturnKeyType.done
            
            let toolbarAndButton = createToolbar()
            let doneButton = toolbarAndButton.1
            let toolbar = toolbarAndButton.0
            doneButton.textView = textbox
            textbox.inputAccessoryView = toolbar
            
            textbox.tag = 0
            self.container.addSubview(textbox)
            self.scoutFormHeight += textbox.frame.height + 10
            
        case "Dropdown":
            let dataPoint = dataPoint as! Dropdown
            
            let options = dataPoint.options
            
            self.pickerLists[dataPoint.name] = options
            
            let label = UILabel(frame: CGRect(x: 10, y: self.scoutFormHeight, width: self.view.frame.width-20, height: 21))
            label.text = dataPoint.name + ":"
            label.tag = 0
            self.container.addSubview(label)
            
            let textField = DropdownTextField(frame: CGRect(x: label.intrinsicContentSize.width+15, y: self.scoutFormHeight, width: self.view.frame.width-20-label.intrinsicContentSize.width-15, height: 21))
            textField.dropdown = dataPoint.name
            //textField.placeholder = "Choose.."
            textField.text = options[0] + " ▾"
            textField.delegate = self
            textField.inputView = self.picker
            textField.tag = 0
            self.container.addSubview(textField)
            self.scoutFormHeight += textField.frame.height + 15
            
        case "NumberBox":
            let dataPoint = dataPoint as! NumberBox
            
            let label = UILabel(frame: CGRect(x: 10, y: self.scoutFormHeight, width: self.view.frame.width-94-45, height: 29))
            label.text = dataPoint.name + ":"
            let stepper = NumberStepper(frame: CGRect(x: self.view.frame.width - 105, y: self.scoutFormHeight, width: 0, height: 0))
            let numberField: UITextField
            if label.intrinsicContentSize.width > (self.view.frame.width-94-50) {
                numberField = UITextField(frame: CGRect(x: self.view.frame.width-94-35, y: self.scoutFormHeight, width: 40, height: 29))
            } else {
                numberField = UITextField(frame: CGRect(x: label.intrinsicContentSize.width+15, y: self.scoutFormHeight, width: 40, height: 29))
            }
            stepper.numberField = numberField
            stepper.numberField?.text = String(dataPoint.start)
            stepper.numberField?.keyboardType = .numberPad
            stepper.maximumValue = Double(dataPoint.max)
            stepper.minimumValue = Double(dataPoint.min)
            stepper.addTarget(self, action: #selector(TeamVC.stepperValueChanged(_:)), for: .valueChanged)
            
            let toolbarAndButton = createToolbar()
            let doneButton = toolbarAndButton.1
            let toolbar = toolbarAndButton.0
            doneButton.textField = stepper.numberField
            stepper.numberField!.inputAccessoryView = toolbar
            
            label.tag = 0
            stepper.tag = 0
            stepper.numberField?.tag = 0
            self.container.addSubview(label)
            self.container.addSubview(stepper.numberField!)
            self.container.addSubview(stepper)
            self.scoutFormHeight += label.frame.height + 10
            
        case "Checkbox":
            let dataPoint = dataPoint as! Checkbox
            
            let label = UILabel(frame: CGRect(x: 10, y: self.scoutFormHeight, width: self.view.frame.width-54-20, height: 31))
            label.text = dataPoint.name
            label.tag = 0
            self.container.addSubview(label)
            
            let check = UISwitch(frame: CGRect(x: self.view.frame.width-65, y: self.scoutFormHeight, width: 0, height: 0))
            check.tintColor = UIColorFromHex("FF8900")
            check.onTintColor = UIColorFromHex("FF8900")
            check.tag = 0
            self.container.addSubview(check)
            
            self.scoutFormHeight += label.frame.height + 10

        default:
            break

        }
    }
    
    func stepperValueChanged(_ sender: UIStepper) {
        let sender = sender as! NumberStepper
        sender.numberField?.text = Int(sender.value).description
    }
    
    func createToolbar() -> (UIToolbar, DoneButton) {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = DoneButton(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TeamVC.clickedDoneButton(_:)))
        toolBar.setItems([flexSpace, doneButton], animated: true)
        return (toolBar, doneButton)
    }
    
    func resizeContainerHeight(_ margin: CGFloat) {
        self.container.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: margin)
        self.scrollView.contentSize = self.container.bounds.size
    }
    
    func createSubmitButton() {
        self.scoutFormHeight += 10
        let button = UIButton(frame: CGRect(x: 100, y: self.scoutFormHeight, width: self.view.frame.width-200, height: 30))
        button.setTitle("Submit", for: UIControlState())
        button.backgroundColor = UIColor.orange
        button.addTarget(self, action: #selector(TeamVC.submitFormClick(_:)), for: .touchUpInside)
        self.scoutFormHeight += button.frame.height + 5
        self.container.addSubview(button)
    }
    
    func submitFormClick(_ sender: UIButton) {
        if scoutFormIsVisible {
            var jsonStringDataArray = "["
            for i in 0 ..< self.container.subviews.count {
                let views = self.container.subviews
                let type = String(describing: Mirror(reflecting: views[i]).subjectType)
                if views[i].tag == 0 {
                    if type == "UILabel" {
                        if i < self.container.subviews.count-1 {
                            if String(describing: Mirror(reflecting: views[i+1]).subjectType) == "UIView" {
                                let label = views[i] as! UILabel
                                jsonStringDataArray += "{\"name\": \"\(escape(label.text!))\"},"
                            }
                        }
                    } else if type == "UITextView" {
                        let textViewLabel = views[i-1] as! UILabel
                        let textView = views[i] as! UITextView
                        jsonStringDataArray += "{\"name\": \"\(escape(textViewLabel.text!))\", \"value\": \"\(escape(textView.text!))\"},"
                        
                    } else if type == "DropdownTextField" {
                        let textField = views[i] as! DropdownTextField
                        if textField.text?.contains("▾") == true {
//                            textField.text = textField.text![0...(textField.text?.characters.count)!-3]
                            textField.text = String(describing: textField.text?.characters.dropLast(2))
                        }
                        jsonStringDataArray += "{\"name\": \"\(escape(textField.dropdown!))\", \"value\": \"\(escape(textField.text!))\"},"
                    } else if type == "NumberStepper" {
                        let stepperLabel = views[i-2] as! UILabel
                        let stepperTextField = views[i-1] as! UITextField
                        jsonStringDataArray += "{\"name\": \"\(escape(String(stepperLabel.text!.characters.dropLast())))\", \"value\": \"\(stepperTextField.text!)\"},"
                    } else if type == "UISwitch" {
                        let checkLabel = views[i-1] as! UILabel
                        let check = views[i] as! UISwitch
                        jsonStringDataArray += "{\"name\": \"\(escape(checkLabel.text!))\", \"value\": \"\(check.isOn)\"},"
                    }
                }
            }
            jsonStringDataArray = String(jsonStringDataArray.characters.dropLast())
            jsonStringDataArray += "]"
            
            let data = ["data": jsonStringDataArray, "team": String(teamNumber), "context": "pit", "regional": storage.string(forKey: "currentRegional")!]

            if Reachability.isConnectedToNetwork() {
                sendSubmission(data)
            } else {
                if let savedReports = storage.array(forKey: "savedReports") {
                    var newSavedReports = savedReports
                    newSavedReports.append(data)
                    storage.set(newSavedReports, forKey: "savedReports")
                } else {
                    let newSavedReports = [data]
                    storage.set(newSavedReports, forKey: "savedReports")
                }
                alert(title: "Submission saved ", message: "You are currently not connected to the internet so we saved your submission locally. It will be sent to the server once an internet connection is established.", buttonText: "OK", viewController: self)
            }
            
            
        }
    }
    
    func sendSubmission(_ data: [String: String]) {
        httpRequest(baseURL+"/submitReport", type: "POST", data: data) { responseText in
            if responseText != "fail" {
                alert(title: "Success", message: "You have successfully submitted the report.", buttonText: "OK", viewController: self)
            } else {
                alert(title: "Oops", message: "Something went wrong :(", buttonText: "OK", viewController: self)
            }
        }
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
    
}

extension TeamVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let pickerView = pickerView as! DropdownPicker
        return self.pickerLists[pickerView.dropdown!]!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let pickerView = pickerView as! DropdownPicker
        return self.pickerLists[pickerView.dropdown!]![row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pickerView = pickerView as! DropdownPicker
        for view in self.container.subviews {
            if String(describing: Mirror(reflecting: view).subjectType) == "DropdownTextField" {
                let textField = view as! DropdownTextField
                if textField.dropdown == self.picker.dropdown {
                    textField.text = self.pickerLists[pickerView.dropdown!]![row] + " ▾"
                }
            }
        }
    }
}

extension TeamVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let textField = textField as! DropdownTextField
        
        let toolbarAndDoneButton = createToolbar()
        let toolbar = toolbarAndDoneButton.0
        let doneButton = toolbarAndDoneButton.1
        
        doneButton.textField = textField
        textField.inputAccessoryView = toolbar
        
        self.picker.dropdown = textField.dropdown
        self.picker.reloadAllComponents()
        self.picker.selectRow(0, inComponent: 0, animated: false)
    }
    
}
