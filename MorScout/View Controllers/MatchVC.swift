//
//  MatchVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 2/19/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class MatchVC: UIViewController {
    
    var matchNumber: Int = 0
    var redTeams = [String]()
    var blueTeams = [String]()
    
    @IBOutlet weak var matchTitle: UINavigationItem!
    
    @IBOutlet weak var redTeam1: UIButton!
    @IBOutlet weak var redTeam2: UIButton!
    @IBOutlet weak var redTeam3: UIButton!
    
    @IBOutlet weak var blueTeam1: UIButton!
    @IBOutlet weak var blueTeam2: UIButton!
    @IBOutlet weak var blueTeam3: UIButton!
    
    @IBOutlet weak var modeTabs: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var container = UIView()
    var scoutTopMargin: CGFloat = 5
    var viewTopMargin: CGFloat = 5
    
    var picker: DropdownPicker = DropdownPicker()
    var pickerLists = [String: Array<String>]()
    
    var dataPoints = [DataPoint]()
    var viewPoints = [String: [ViewPoint]]()
    var viewData = [String: JSON]()
    
    var scoutFormIsVisible = false
    var viewFormIsVisible = false
    
    var scoutFormDataIsLoaded = false
    var viewFormDataIsLoaded = [String: Bool]()
    
    var selectedTeam = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkConnectionAndSync()
        
        matchTitle.title = "Match \(matchNumber)"
        redTeam1.setTitle(redTeams[0], forState: .Normal)
        redTeam2.setTitle(redTeams[1], forState: .Normal)
        redTeam3.setTitle(redTeams[2], forState: .Normal)
        blueTeam1.setTitle(blueTeams[0], forState: .Normal)
        blueTeam2.setTitle(blueTeams[1], forState: .Normal)
        blueTeam3.setTitle(blueTeams[2], forState: .Normal)
        
        for(var i = 0; i < 3; i++){
            viewFormDataIsLoaded[redTeams[i]] = false
            viewFormDataIsLoaded[blueTeams[i]] = false
        }
        
        modeTabs.hidden = true
        modeTabs.selectedSegmentIndex = -1
        
        picker.delegate = self
        picker.dataSource = self
        
        self.scrollView.addSubview(self.container)
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    func restoreAllButtonColors() {
        redTeam1.backgroundColor = UIColorFromHex("FF0000", alpha: 0.55)
        redTeam2.backgroundColor = UIColorFromHex("FF0000", alpha: 0.55)
        redTeam3.backgroundColor = UIColorFromHex("FF0000", alpha: 0.55)
        blueTeam1.backgroundColor = UIColorFromHex("007AFF", alpha: 0.6)
        blueTeam2.backgroundColor = UIColorFromHex("007AFF", alpha: 0.6)
        blueTeam3.backgroundColor = UIColorFromHex("007AFF", alpha: 0.6)
    }
    
    @IBAction func redTeam1Click(sender: UIButton) {
        restoreAllButtonColors()
        redTeam1.backgroundColor = UIColorFromHex("FF0000", alpha: 1)
        selectedTeam = Int((redTeam1.titleLabel?.text)!)!
        modeTabs.hidden = false
        modeTabs.selectedSegmentIndex = 0
        changeModeTabs(modeTabs)
    }
    @IBAction func redTeam2Click(sender: UIButton) {
        restoreAllButtonColors()
        redTeam2.backgroundColor = UIColorFromHex("FF0000", alpha: 1)
        selectedTeam = Int((redTeam2.titleLabel?.text)!)!
        modeTabs.hidden = false
        modeTabs.selectedSegmentIndex = 0
        changeModeTabs(modeTabs)
    }
    @IBAction func redTeam3Click(sender: UIButton) {
        restoreAllButtonColors()
        redTeam3.backgroundColor = UIColorFromHex("FF0000", alpha: 1)
        selectedTeam = Int((redTeam3.titleLabel?.text)!)!
        modeTabs.hidden = false
        modeTabs.selectedSegmentIndex = 0
        changeModeTabs(modeTabs)
    }
    @IBAction func blueTeam1Click(sender: UIButton) {
        restoreAllButtonColors()
        blueTeam1.backgroundColor = UIColorFromHex("007AFF", alpha: 1)
        selectedTeam = Int((blueTeam1.titleLabel?.text)!)!
        modeTabs.hidden = false
        modeTabs.selectedSegmentIndex = 0
        changeModeTabs(modeTabs)
    }
    @IBAction func blueTeam2Click(sender: UIButton) {
        restoreAllButtonColors()
        blueTeam2.backgroundColor = UIColorFromHex("007AFF", alpha: 1)
        selectedTeam = Int((blueTeam2.titleLabel?.text)!)!
        modeTabs.hidden = false
        modeTabs.selectedSegmentIndex = 0
        changeModeTabs(modeTabs)
    }
    @IBAction func blueTeam3Click(sender: UIButton) {
        restoreAllButtonColors()
        blueTeam3.backgroundColor = UIColorFromHex("007AFF", alpha: 1)
        selectedTeam = Int((blueTeam3.titleLabel?.text)!)!
        modeTabs.hidden = false
        modeTabs.selectedSegmentIndex = 0
        changeModeTabs(modeTabs)
    }
    
    @IBAction func changeModeTabs(sender: UISegmentedControl) {
        switch modeTabs.selectedSegmentIndex {
        case 0:
            hideViewForm()
            showScoutForm()
        case 1:
            hideScoutForm()
            showViewForm()
        default:
            break
        }
    }
    
    // MARK: - Scout Form Generation
    
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
                if let dataPointsData = storage.objectForKey("matchDataPoints") {
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
        scoutFormIsVisible = true
    }
    
    func loadScoutForm() {
        httpRequest(baseURL+"/getScoutForm", type: "POST", data: ["context": "match"]) {responseText in
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
                storage.setObject(dataPointsData, forKey: "matchDataPoints")
                
                self.scoutFormDataIsLoaded = true
                
                self.resizeContainer(self.scoutTopMargin)
                

            })
        }
    }
    
    func retrieveScoutFormFromCache() {
        if let dataPointsData = storage.objectForKey("matchDataPoints") {
            let cachedDataPoints = NSKeyedUnarchiver.unarchiveObjectWithData(dataPointsData as! NSData) as? [DataPoint]
            
            for cachedDataPoint in cachedDataPoints! {
                self.createDataPoint(cachedDataPoint)
            }
            
            createSubmitButton()
            
            scoutFormDataIsLoaded = true
            
            resizeContainer(self.scoutTopMargin)
        }
    }
    
    func hideScoutForm() {
        for view in self.container.subviews {
            if view.tag == 0 {
                view.hidden = true
            }
        }
        scoutFormIsVisible = false
    }
    
    // MARK: - View Form Generation
    
    func showViewForm() {
        if viewFormDataIsLoaded[String(selectedTeam)] == true {
            if !viewFormIsVisible {
                for view in container.subviews {
                    if view.tag == self.selectedTeam {
                        view.hidden = false
                    }
                }
                resizeContainer(self.viewTopMargin)
            }
        }else{
            if Reachability.isConnectedToNetwork() {
                loadViewForm()
            }else{
                alert(title: "Cannot load scouted reports", message: "Unfortunately you need to be connected to the internet to view previous reports", buttonText: "OK", viewController: self)
//                if let matchViewPoints = storage.objectForKey("matchViewPoints") {
//                    let cachedViewPoints = NSKeyedUnarchiver.unarchiveObjectWithData(matchViewPoints as! NSData) as? [ViewPoint]
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
        httpRequest(baseURL+"/getMatchReports", type: "POST", data:[
            "match": String(matchNumber),
            "team": String(selectedTeam)
        ]){ responseText in
                
            let data = parseJSON(responseText)
            
//            var yourTeamReports = [Report]()
//            var otherTeamsReports = [Report]()
//            
//            for(_, subJson):(String, JSON) in data["yourTeam"]{
//                yourTeamReports.append(Report(json: subJson))
//            }
//        
//            for(_, subJson):(String, JSON) in data["otherTeams"]{
//                otherTeamsReports.append(Report(json: subJson))
//            }
//            
//            if let currentRegional = storage.stringForKey("currentRegional") {
//            
//                MatchDataStorage.sharedInstance.data[currentRegional] = ["\(self.matchNumber)": ["\(self.selectedTeam)": ["yourTeam": yourTeamReports]]]
//                
//                MatchDataStorage.sharedInstance.data[currentRegional] = ["\(self.matchNumber)": ["\(self.selectedTeam)": ["otherTeams": otherTeamsReports]]]
//                
//            }
//            
//            print("ON LOAD MATCH DATA:")
//            print(MatchDataStorage.sharedInstance.data)
            
            
            self.viewFormDataIsLoaded[String(self.selectedTeam)] = true

                
            dispatch_async(dispatch_get_main_queue(),{
                
                self.viewTopMargin = 5
                
                if data["yourTeam"].count == 0 && data["otherTeams"].count == 0 {
                    self.viewTopMargin += 25
                    let label = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                    label.text = "No Reports"
                    label.font = UIFont(name: "Helvetica-Light", size: 22.0)
                    label.textAlignment = .Center
                    label.tag = self.selectedTeam
                    self.container.addSubview(label)
                    self.viewTopMargin += label.frame.height + 5
                }
    
                if data["yourTeam"].count != 0 {
                    let label = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                    label.text = "Your Team"
                    label.font = UIFont(name: "Helvetica-Light", size: 22.0)
                    label.textAlignment = .Center
                    label.tag = self.selectedTeam
                    self.container.addSubview(label)
                    self.viewTopMargin += label.frame.height + 5
                    
                    let line = UIView(frame: CGRectMake(40, self.viewTopMargin, self.view.frame.width-80, 1))
                    line.backgroundColor = UIColor.lightGrayColor()
                    line.tag = self.selectedTeam
                    self.container.addSubview(line)
                    self.viewTopMargin += line.frame.height + 10
                    
                    for(i, subJson):(String, JSON) in data["yourTeam"] {
                        let reportNumber = Int(i)!+1
                        let label = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                        label.text = "Report \(reportNumber)"
                        label.font = UIFont(name: "Helvetica-Light", size: 21.0)
                        label.textAlignment = .Center
                        label.tag = self.selectedTeam
                        self.container.addSubview(label)
                        self.viewTopMargin += label.frame.height + 5
                        
                        let line = UIView(frame: CGRectMake(60, self.viewTopMargin, self.view.frame.width-120, 1))
                        line.backgroundColor = UIColor.lightGrayColor()
                        line.tag = self.selectedTeam
                        self.container.addSubview(line)
                        self.viewTopMargin += line.frame.height + 10
                        
                        for(_, subJson):(String, JSON) in subJson["data"] {
                            if String(subJson["value"]) == "null" {
                                let label = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                                label.text = String(subJson["name"])
                                label.font = UIFont(name: "Helvetica-Light", size: 20.0)
                                label.textAlignment = .Center
                                label.tag = self.selectedTeam
                                self.container.addSubview(label)
                                self.viewTopMargin += label.frame.height + 5
                                
                                let line = UIView(frame: CGRectMake(80, self.viewTopMargin, self.view.frame.width-160, 1))
                                line.backgroundColor = UIColor.lightGrayColor()
                                line.tag = self.selectedTeam
                                self.container.addSubview(line)
                                self.viewTopMargin += line.frame.height + 10
                            }else{
                                let key = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                                key.text = String(subJson["name"])
                                key.tag = self.selectedTeam
                                self.container.addSubview(key)
                                
                                let value = UILabel(frame: CGRectMake(self.view.frame.width-150, self.viewTopMargin, 140 , heightForView(String(subJson["value"]), width: 140)))
                                value.numberOfLines = 0
                                value.text = String(subJson["value"])
                                value.tag = self.selectedTeam
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
                    label.tag = self.selectedTeam
                    self.container.addSubview(label)
                    self.viewTopMargin += label.frame.height + 5
                    
                    let line = UIView(frame: CGRectMake(40, self.viewTopMargin, self.view.frame.width-80, 1))
                    line.backgroundColor = UIColor.lightGrayColor()
                    line.tag = self.selectedTeam
                    self.container.addSubview(line)
                    self.viewTopMargin += line.frame.height + 10
                    
                    
                    for(i, subJson):(String, JSON) in data["otherTeams"] {
                        let reportNumber = Int(i)!+1
                        let label = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                        label.text = "Report \(reportNumber)"
                        label.font = UIFont(name: "Helvetica-Light", size: 22.0)
                        label.textAlignment = .Center
                        label.tag = self.selectedTeam
                        self.container.addSubview(label)
                        self.viewTopMargin += label.frame.height + 5
                        
                        let line = UIView(frame: CGRectMake(60, self.viewTopMargin, self.view.frame.width-120, 1))
                        line.backgroundColor = UIColor.lightGrayColor()
                        line.tag = self.selectedTeam
                        self.container.addSubview(line)
                        self.viewTopMargin += line.frame.height + 10
                        
                        for(_, subJson):(String, JSON) in subJson["data"] {
                            if String(subJson["value"]) == "null" {
                                let label = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                                label.text = String(subJson["name"])
                                label.font = UIFont(name: "Helvetica-Light", size: 20.0)
                                label.textAlignment = .Center
                                label.tag = self.selectedTeam
                                self.container.addSubview(label)
                                self.viewTopMargin += label.frame.height + 5
                                
                                let line = UIView(frame: CGRectMake(80, self.viewTopMargin, self.view.frame.width-160, 1))
                                line.backgroundColor = UIColor.lightGrayColor()
                                line.tag = self.selectedTeam
                                self.container.addSubview(line)
                                self.viewTopMargin += line.frame.height + 10
                            }else{
                                let key = UILabel(frame: CGRectMake(10, self.viewTopMargin, self.view.frame.width - 20, 21))
                                key.text = String(subJson["name"])
                                key.tag = self.selectedTeam
                                self.container.addSubview(key)
                                
                                let value = UILabel(frame: CGRectMake(self.view.frame.width-150, self.viewTopMargin, 140 , heightForView(String(subJson["value"]), width: 140)))
                                value.numberOfLines = 0
                                value.text = String(subJson["value"])
                                value.tag = self.selectedTeam
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
    
    func hideViewForm() {
        for view in self.container.subviews {
            if view.tag != 0 {
                view.hidden = true
            }
        }
        viewFormIsVisible = false
    }
    
    // MARK: - Misc
    
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
            textField.placeholder = "Choose.."
            textField.delegate = self
            textField.inputView = self.picker
            textField.tag = 0
            self.container.addSubview(textField)
            self.scoutTopMargin += textField.frame.height + 15

        }else if type == "NumberBox" {
            let dataPoint = dataPoint as! NumberBox
            
            let label = UILabel(frame: CGRectMake(10, self.scoutTopMargin, self.view.frame.width-20, 29))
            label.text = dataPoint.name + ":"
            let stepper = NumberStepper(frame: CGRectMake(self.view.frame.width - 105, self.scoutTopMargin, 0, 0))
            let numberField = UITextField(frame: CGRectMake(label.intrinsicContentSize().width+15, self.scoutTopMargin, 40, 29))
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
            
            let label = UILabel(frame: CGRectMake(10, self.scoutTopMargin, self.view.frame.width-20, 31))
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
                if type == "UILabel" && String(Mirror(reflecting: views[i+1]).subjectType) == "UIView" {
                    let label = views[i] as! UILabel
                    jsonStringDataArray += "{\"name\": \"\(label.text!)\"},"
                }else if type == "UITextView" {
                    let textViewLabel = views[i-1] as! UILabel
                    let textView = views[i] as! UITextView
                    jsonStringDataArray += "{\"name\": \"\(textViewLabel.text!)\", \"value\": \"\(textView.text!)\"},"
                }else if type == "DropdownTextField" {
                    let textField = views[i] as! DropdownTextField
                    jsonStringDataArray += "{\"name\": \"\(textField.dropdown!)\", \"value\": \"\(textField.text!)\"},"
                }else if type == "NumberStepper" {
                    let stepperLabel = views[i-2] as! UILabel
                    let stepperTextField = views[i-1] as! UITextField
                    jsonStringDataArray += "{\"name\": \"\(String(stepperLabel.text!.characters.dropLast()))\", \"value\": \"\(stepperTextField.text!)\"},"
                }else if type == "UISwitch" {
                    let checkLabel = views[i-1] as! UILabel
                    let check = views[i] as! UISwitch
                    jsonStringDataArray += "{\"name\": \"\(checkLabel.text!)\", \"value\": \"\(check.on)\"},"
                }
            }
            jsonStringDataArray = String(jsonStringDataArray.characters.dropLast())
            jsonStringDataArray += "]"
            
            let data = ["data": jsonStringDataArray, "team": String(selectedTeam), "context": "match", "match": String(matchNumber)]
            
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

extension MatchVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
                    textField.text = self.pickerLists[pickerView.dropdown!]![row]
                }
            }
        }
    }
    
}

extension MatchVC: UITextFieldDelegate {
    
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

