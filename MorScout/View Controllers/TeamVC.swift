//
//  TeamVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/3/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class TeamVC: UIViewController {
    
    var teamNumber = 0
    var teamName = ""
    
    @IBOutlet weak var teamTitle: UINavigationItem!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamWebLink: UITextView!
    @IBOutlet weak var teamLocation: UILabel!
    @IBOutlet weak var modeTabs: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var container = UIView()
    var scoutTopMargin: CGFloat = 5
    var viewTopMargin: CGFloat = 5
    
    var picker: DropdownPicker = DropdownPicker()
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
            httpRequest(baseURL+"/getTeamInfo", type: "POST", data: ["teamNumber": String(teamNumber)]){responseText in
                let teamInfo = parseJSON(responseText)
                dispatch_async(dispatch_get_main_queue(),{
                    self.teamWebLink.text = String(teamInfo["website"])
                    self.teamLocation.text = String(teamInfo["location"])
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
    
    @IBAction func changeModeTabs(sender: UISegmentedControl) {
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
                        view.hidden = false
                    }
                }
                resizeContainer(self.scoutTopMargin)
            }
        }else{
            if Reachability.isConnectedToNetwork() {
                loadScoutForm()
            }else{
                if let dataPointsData = storage.objectForKey("teamDataPoints") {
                    let cachedDataPoints = NSKeyedUnarchiver.unarchiveObjectWithData(dataPointsData as! NSData) as? [DataPoint]
                    
                    if cachedDataPoints!.count == 0 {
                        alert(title: "No Data Found", message: "In order to load the data, you need to have connected to the internet at least once.", buttonText: "OK", viewController: self)
                    }else{
                        retrieveScoutFormFromCache()
                    }
                }else{
                    alert(title: "No Data Found", message: "In order to load the data, you need to have connected to the internet at least once.", buttonText: "OK", viewController: self)
                }
            }
        }
        self.scoutFormIsVisible = true
        
    }
    
    func loadScoutForm() {
        httpRequest(baseURL+"/getScoutForm", type: "POST", data: ["context": "pit"]) {responseText in
            let formData = parseJSON(responseText)
            dispatch_async(dispatch_get_main_queue(),{
                
                for(i, subJson):(String, JSON) in formData {
                    let type = String(subJson["type"])
                    if type == "label" {
                        self.dataPoints.append(Label(json: subJson))
                    }else if type == "text" {
                        self.dataPoints.append(TextBox(json: subJson))
                    }else if type == "dropdown" || type == "radio" {
                        self.dataPoints.append(Dropdown(json: subJson))
                    }else if type == "number" {
                        self.dataPoints.append(NumberBox(json: subJson))
                    }else if type == "checkbox" {
                        self.dataPoints.append(Checkbox(json: subJson))
                    }
                    self.createDataPoint(self.dataPoints[Int(i)!])
                }
                
                self.createSubmitButton()
                
                let dataPointsData = NSKeyedArchiver.archivedDataWithRootObject(self.dataPoints)
                storage.setObject(dataPointsData, forKey: "teamDataPoints")
                
                self.scoutFormDataIsLoaded = true
                
                self.resizeContainer(self.scoutTopMargin)
                
            })
        }
    }
    
    func retrieveScoutFormFromCache() {
        if let dataPointsData = storage.objectForKey("teamDataPoints") {
            let cachedDataPoints = NSKeyedUnarchiver.unarchiveObjectWithData(dataPointsData as! NSData) as? [DataPoint]
            
            for cachedDataPoint in cachedDataPoints! {
                self.createDataPoint(cachedDataPoint)
            }
            
            createSubmitButton()
            
            scoutFormDataIsLoaded = true
            
            self.resizeContainer(self.scoutTopMargin)

        }
    }
    
    func hideScoutFormElements() {
        for view in self.container.subviews {
            if view.tag == 0 {
                view.hidden = true
            }
        }
        scoutFormIsVisible = false
    }
    
    func showViewForm() {
        if viewFormDataIsLoaded {
            if !viewFormIsVisible {
                for view in container.subviews {
                    if view.tag == teamNumber {
                        view.hidden = false
                    }
                }
            }
            self.resizeContainer(self.viewTopMargin)
        }else{
            if Reachability.isConnectedToNetwork() {
                loadViewForm()
            }else{
                alert(title: "Cannot load scouted reports", message: "Unfortunately you need to be connected to the internet to view previous reports", buttonText: "OK", viewController: self)
                
//                if let teamViewData = storage.objectForKey("teamViewData") {
//                    let cachedViewPoints = NSKeyedUnarchiver.unarchiveObjectWithData(teamViewData as! NSData) as? [ViewPoint]
//                    
//                    if cachedViewPoints!.count == 0 {
//                        alert(title: "No Data Found", message: "In order to load the data, you need to have connected to the internet at least once.", buttonText: "OK", viewController: self)
//                    }else{
//                        retrieveViewDataFromCache()
//                    }
//                }else{
//                    alert(title: "No Data Found", message: "In order to load the data, you need to have connected to the internet at least once.", buttonText: "OK", viewController: self)
//                }
            }
        }
        self.viewFormIsVisible = true
        
    }
    
    func loadViewForm() {
        httpRequest(baseURL+"/getTeamReports", type: "POST", data: ["reportContext": "pit", "teamNumber": String(teamNumber)]) { responseText in
            
            let data = parseJSON(responseText)
            
            self.viewFormDataIsLoaded = true
            
            dispatch_async(dispatch_get_main_queue(),{
                
                self.viewTopMargin = 5
                
                if data["yourTeam"].count == 0 && data["otherTeams"].count == 0 {
                    self.viewTopMargin += 25
                    let label = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                    label.text = "No Reports"
                    label.font = UIFont(name: "Helvetica-Light", size: 22.0)
                    label.textAlignment = .Center
                    label.tag = self.teamNumber
                    self.container.addSubview(label)
                    self.viewTopMargin += label.frame.height + 5
                }
                
                if data["yourTeam"].count != 0 {
                    let label = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                    label.text = "Your Team"
                    label.font = UIFont(name: "Helvetica-Light", size: 22.0)
                    label.textAlignment = .Center
                    label.tag = self.teamNumber
                    self.container.addSubview(label)
                    self.viewTopMargin += label.frame.height + 5
                    
                    let line = UIView(frame: CGRectMake(40, self.viewTopMargin, self.view.frame.width-80, 1))
                    line.backgroundColor = UIColor.lightGrayColor()
                    line.tag = self.teamNumber
                    self.container.addSubview(line)
                    self.viewTopMargin += line.frame.height + 10
                    
                    for(i, subJson):(String, JSON) in data["yourTeam"] {
                        let reportNumber = Int(i)!+1
                        let label = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                        label.text = "Report \(reportNumber)"
                        label.font = UIFont(name: "Helvetica-Light", size: 21.0)
                        label.textAlignment = .Center
                        label.tag = self.teamNumber
                        self.container.addSubview(label)
                        self.viewTopMargin += label.frame.height + 5
                        
                        let line = UIView(frame: CGRectMake(60, self.viewTopMargin, self.view.frame.width-120, 1))
                        line.backgroundColor = UIColor.lightGrayColor()
                        line.tag = self.teamNumber
                        self.container.addSubview(line)
                        self.viewTopMargin += line.frame.height + 10
                        
                        for(_, subJson):(String, JSON) in subJson["data"] {
                            if String(subJson["value"]) == "null" {
                                let label = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                                label.text = String(subJson["name"])
                                label.font = UIFont(name: "Helvetica-Light", size: 20.0)
                                label.textAlignment = .Center
                                label.tag = self.teamNumber
                                self.container.addSubview(label)
                                self.viewTopMargin += label.frame.height + 5
                                
                                let line = UIView(frame: CGRectMake(80, self.viewTopMargin, self.view.frame.width-160, 1))
                                line.backgroundColor = UIColor.lightGrayColor()
                                line.tag = self.teamNumber
                                self.container.addSubview(line)
                                self.viewTopMargin += line.frame.height + 10
                            }else{
                                let key = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 160, 21))
                                key.text = String(subJson["name"])
                                key.tag = self.teamNumber
                                self.container.addSubview(key)
                                var height = heightForView(String(subJson["value"]), width: 140)
                                if height == 0 {
                                    height = 21
                                }
                                let value = UILabel(frame: CGRectMake(self.view.frame.width-150, self.viewTopMargin, 140 , height))
                                value.numberOfLines = 0
                                if String(subJson["value"]) == "" {
                                    value.text = "N/A"
                                }else{
                                    value.text = String(subJson["value"])
                                }

                                value.tag = self.teamNumber
                                self.container.addSubview(value)
                                
                                self.viewTopMargin += value.frame.height + 5
                            }
                        }
                    }
                }
                
                if data["otherTeams"].count != 0 {
                    
                    let label = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                    label.text = "Other Teams"
                    label.font = UIFont(name: "Helvetica-Light", size: 22.0)
                    label.textAlignment = .Center
                    label.tag = self.teamNumber
                    self.container.addSubview(label)
                    self.viewTopMargin += label.frame.height + 5
                    
                    let line = UIView(frame: CGRectMake(40, self.viewTopMargin, self.view.frame.width-80, 1))
                    line.backgroundColor = UIColor.lightGrayColor()
                    line.tag = self.teamNumber
                    self.container.addSubview(line)
                    self.viewTopMargin += line.frame.height + 10
                    
                    
                    for(i, subJson):(String, JSON) in data["otherTeams"] {
                        let reportNumber = Int(i)!+1
                        let label = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                        label.text = "Report \(reportNumber)"
                        label.font = UIFont(name: "Helvetica-Light", size: 21.0)
                        label.textAlignment = .Center
                        label.tag = self.teamNumber
                        self.container.addSubview(label)
                        self.viewTopMargin += label.frame.height + 5
                        
                        let line = UIView(frame: CGRectMake(60, self.viewTopMargin, self.view.frame.width-120, 1))
                        line.backgroundColor = UIColor.lightGrayColor()
                        line.tag = self.teamNumber
                        self.container.addSubview(line)
                        self.viewTopMargin += line.frame.height + 10
                        
                        for(_, subJson):(String, JSON) in subJson["data"] {
                            if String(subJson["value"]) == "null" {
                                let label = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                                label.text = String(subJson["name"])
                                label.font = UIFont(name: "Helvetica-Light", size: 20.0)
                                label.textAlignment = .Center
                                label.tag = self.teamNumber
                                self.container.addSubview(label)
                                self.viewTopMargin += label.frame.height + 5
                                
                                let line = UIView(frame: CGRectMake(80, self.viewTopMargin, self.view.frame.width-160, 1))
                                line.backgroundColor = UIColor.lightGrayColor()
                                line.tag = self.teamNumber
                                self.container.addSubview(line)
                                self.viewTopMargin += line.frame.height + 10
                            }else{
                                let key = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 160, 21))
                                key.text = String(subJson["name"])
                                key.tag = self.teamNumber
                                self.container.addSubview(key)
                                var height = heightForView(String(subJson["value"]), width: 140)
                                if height == 0 {
                                    height = 21
                                }
                                let value = UILabel(frame: CGRectMake(self.view.frame.width-150, self.viewTopMargin, 140 , height))
                                value.numberOfLines = 0
                                if String(subJson["value"]) == "" {
                                    value.text = "N/A"
                                }else{
                                    value.text = String(subJson["value"])
                                }

                                value.tag = self.teamNumber
                                self.container.addSubview(value)
                                
                                self.viewTopMargin += value.frame.height + 5
                            }
                        }
                    }
                }
                
                self.resizeContainer(self.viewTopMargin)
                
            })
        }
    }
    
    func retrieveViewDataFromCache() {
        
    }
    
    func hideViewFormElements() {
        for view in self.container.subviews {
            if view.tag != 0 {
                view.hidden = true
            }
        }
        viewFormIsVisible = false
    }
    
    func createDataPoint(dataPoint: DataPoint) {
        
        //the tags for scout form elements are being set to 0
        
        let type = String(Mirror(reflecting: dataPoint).subjectType)
        
        if type == "Label" {
            let dataPoint = dataPoint as! Label
            
            let label = UILabel(frame: CGRectMake(10, self.scoutTopMargin, self.view.frame.width-20, 26))
            label.text = dataPoint.name
            label.font = UIFont(name: "Helvetica-Light", size: 22.0)
            label.textAlignment = .Center
            label.tag = 0
            self.container.addSubview(label)
            self.scoutTopMargin += label.frame.height + 5
            
            let line = UIView(frame: CGRectMake(80, self.scoutTopMargin, self.view.frame.width-160, 1))
            line.backgroundColor = UIColor.lightGrayColor()
            line.tag = 0
            self.container.addSubview(line)
            self.scoutTopMargin += line.frame.height + 10
            
        }else if type == "TextBox" {
            let dataPoint = dataPoint as! TextBox
            
            let label = UILabel(frame: CGRectMake(10, self.scoutTopMargin, self.view.frame.width-20, 21))
            label.text = dataPoint.name
            label.font = UIFont(name: "Helvetica-Light", size: 17.0)
            label.textColor = UIColor.blackColor()
            label.tag = 0
            self.container.addSubview(label)
            self.scoutTopMargin += label.frame.height + 5
            
            let textbox = UITextView(frame: CGRectMake(10, self.scoutTopMargin, self.view.frame.width-20, 90))
            textbox.font = UIFont.systemFontOfSize(15)
            textbox.autocorrectionType = UITextAutocorrectionType.No
            textbox.keyboardType = UIKeyboardType.Default
            textbox.returnKeyType = UIReturnKeyType.Done
            
            let toolbarAndButton = createToolbar()
            let doneButton = toolbarAndButton.1
            let toolbar = toolbarAndButton.0
            doneButton.textView = textbox
            textbox.inputAccessoryView = toolbar
            
            textbox.tag = 0
            self.container.addSubview(textbox)
            self.scoutTopMargin += textbox.frame.height + 10
            
        }else if type == "Dropdown" {
            let dataPoint = dataPoint as! Dropdown
            
            let options = dataPoint.options
            
            self.pickerLists[dataPoint.name] = options
            
            let label = UILabel(frame: CGRectMake(10, self.scoutTopMargin, self.view.frame.width-20, 21))
            label.text = dataPoint.name + ":"
            label.tag = 0
            self.container.addSubview(label)
            
            let textField = DropdownTextField(frame: CGRectMake(label.intrinsicContentSize().width+15, self.scoutTopMargin, self.view.frame.width-20-label.intrinsicContentSize().width-15, 21))
            textField.dropdown = dataPoint.name
            //textField.placeholder = "Choose.."
            textField.text = options[0] + " ▾"
            textField.delegate = self
            textField.inputView = self.picker
            textField.tag = 0
            self.container.addSubview(textField)
            self.scoutTopMargin += textField.frame.height + 15
            
        }else if type == "NumberBox" {
            let dataPoint = dataPoint as! NumberBox
            
            let label = UILabel(frame: CGRectMake(10, self.scoutTopMargin, self.view.frame.width-94-45, 29))
            label.text = dataPoint.name + ":"
            let stepper = NumberStepper(frame: CGRectMake(self.view.frame.width - 105, self.scoutTopMargin, 0, 0))
            let numberField: UITextField
            if label.intrinsicContentSize().width > (self.view.frame.width-94-50) {
                numberField = UITextField(frame: CGRectMake(self.view.frame.width-94-35, self.scoutTopMargin, 40, 29))
            }else{
                numberField = UITextField(frame: CGRectMake(label.intrinsicContentSize().width+15, self.scoutTopMargin, 40, 29))
            }
            stepper.numberField = numberField
            stepper.numberField?.text = String(dataPoint.start)
            stepper.numberField?.keyboardType = .NumberPad
            stepper.maximumValue = Double(dataPoint.max)
            stepper.minimumValue = Double(dataPoint.min)
            stepper.addTarget(self, action: "stepperValueChanged:", forControlEvents: .ValueChanged)
            
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
            self.scoutTopMargin += label.frame.height + 10
            
        }else if type == "Checkbox" {
            let dataPoint = dataPoint as! Checkbox
            
            let label = UILabel(frame: CGRectMake(10, self.scoutTopMargin, self.view.frame.width-54-20, 31))
            label.text = dataPoint.name
            label.tag = 0
            self.container.addSubview(label)
            
            let check = UISwitch(frame: CGRectMake(self.view.frame.width-65, self.scoutTopMargin, 0, 0))
            check.tintColor = UIColorFromHex("FF8900")
            check.onTintColor = UIColorFromHex("FF8900")
            check.tag = 0
            self.container.addSubview(check)
            
            self.scoutTopMargin += label.frame.height + 10
            
        }
    }
    
    func stepperValueChanged(sender: UIStepper) {
        let sender = sender as! NumberStepper
        sender.numberField?.text = Int(sender.value).description
    }
    
    func createToolbar() -> (UIToolbar, DoneButton) {
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let doneButton = DoneButton(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "clickedDoneButton:")
        toolBar.setItems([flexSpace, doneButton], animated: true)
        return (toolBar, doneButton)
    }
    
    func resizeContainer(margin: CGFloat) {
        self.container.frame = CGRectMake(0, 0, self.view.frame.width, margin)
        self.scrollView.contentSize = self.container.bounds.size
    }
    
    func createSubmitButton() {
        self.scoutTopMargin += 10
        let button = UIButton(frame: CGRectMake(100, self.scoutTopMargin, self.view.frame.width-200, 30))
        button.setTitle("Submit", forState: .Normal)
        button.backgroundColor = UIColor.orangeColor()
        button.addTarget(self, action: "submitFormClick:", forControlEvents: .TouchUpInside)
        self.scoutTopMargin += button.frame.height + 5
        self.container.addSubview(button)
    }
    
    func submitFormClick(sender: UIButton) {
        if scoutFormIsVisible {
            var jsonStringDataArray = "["
            for (var i = 0; i < self.container.subviews.count; i++) {
                let views = self.container.subviews
                let type = String(Mirror(reflecting: views[i]).subjectType)
                if views[i].tag == 0 {
                    if type == "UILabel" {
                        if i < self.container.subviews.count-1 {
                            if String(Mirror(reflecting: views[i+1]).subjectType) == "UIView" {
                                let label = views[i] as! UILabel
                                jsonStringDataArray += "{\"name\": \"\(escape(label.text!))\"},"
                            }
                        }
                    }else if type == "UITextView" {
                        let textViewLabel = views[i-1] as! UILabel
                        let textView = views[i] as! UITextView
                        jsonStringDataArray += "{\"name\": \"\(escape(textViewLabel.text!))\", \"value\": \"\(escape(textView.text!))\"},"
                        
                    }else if type == "DropdownTextField" {
                        let textField = views[i] as! DropdownTextField
                        if textField.text?.containsString("▾") == true {
                            textField.text = textField.text![0...(textField.text?.characters.count)!-3]
                        }
                        jsonStringDataArray += "{\"name\": \"\(escape(textField.dropdown!))\", \"value\": \"\(escape(textField.text!))\"},"
                    }else if type == "NumberStepper" {
                        let stepperLabel = views[i-2] as! UILabel
                        let stepperTextField = views[i-1] as! UITextField
                        jsonStringDataArray += "{\"name\": \"\(escape(String(stepperLabel.text!.characters.dropLast())))\", \"value\": \"\(stepperTextField.text!)\"},"
                    }else if type == "UISwitch" {
                        let checkLabel = views[i-1] as! UILabel
                        let check = views[i] as! UISwitch
                        jsonStringDataArray += "{\"name\": \"\(escape(checkLabel.text!))\", \"value\": \"\(check.on)\"},"
                    }
                }
            }
            jsonStringDataArray = String(jsonStringDataArray.characters.dropLast())
            jsonStringDataArray += "]"
            
            let data = ["data": jsonStringDataArray, "team": String(teamNumber), "context": "pit", "regional": storage.stringForKey("currentRegional")!]

            if Reachability.isConnectedToNetwork() {
                sendSubmission(data)
            }else{
                if let savedReports = storage.arrayForKey("savedReports") {
                    var newSavedReports = savedReports
                    newSavedReports.append(data)
                    storage.setObject(newSavedReports, forKey: "savedReports")
                }else{
                    let newSavedReports = [data]
                    storage.setObject(newSavedReports, forKey: "savedReports")
                }
                alert(title: "Submission saved ", message: "You are currently not connected to the internet so we saved your submission locally. It will be sent to the server once an internet connection is established.", buttonText: "OK", viewController: self)
            }
            
            
        }
    }
    
    func sendSubmission(data: [String: String]) {
        httpRequest(baseURL+"/submitReport", type: "POST", data: data) { responseText in
            if responseText != "fail" {
                alert(title: "Success", message: "You have successfully submitted the report.", buttonText: "OK", viewController: self)
            }else{
                alert(title: "Oops", message: "Something went wrong :(", buttonText: "OK", viewController: self)
            }
        }
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
    
}

extension TeamVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let pickerView = pickerView as! DropdownPicker
        return self.pickerLists[pickerView.dropdown!]!.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let pickerView = pickerView as! DropdownPicker
        return self.pickerLists[pickerView.dropdown!]![row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pickerView = pickerView as! DropdownPicker
        for view in self.container.subviews {
            if String(Mirror(reflecting: view).subjectType) == "DropdownTextField" {
                let textField = view as! DropdownTextField
                if textField.dropdown == self.picker.dropdown {
                    textField.text = self.pickerLists[pickerView.dropdown!]![row] + " ▾"
                }
            }
        }
    }
}

extension TeamVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
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