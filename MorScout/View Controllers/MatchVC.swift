//
//  MatchVC.swift
//  MorScout
//
//  Created by Farbod Rafezy on 2/19/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import SwiftyJSON

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

    /// This view "contains" all of the elements in
    /// the scout form or view form and changes in size
    /// based on the amount of information needed to be
    /// displayed at the current time.
    /// This UIView element will be referred to as
    /// the "container" in most documentation in this file.
    var container = UIView()
    var scoutFormHeight: CGFloat = 5
    var viewFormHeight: CGFloat = 5
    let strategyBoxHeight: CGFloat = 100
    let strategySaveButtonHeight: CGFloat = 30
    
    var picker: DropdownPicker = DropdownPicker()
    /// The array of options for each DropdownPicker
    /// with a String name.
    var pickerLists = [String: Array<String>]()
    
    var dataPoints = [DataPoint]()
    var viewData = [String: JSON]()
    
    var scoutFormIsVisible = false
    var viewFormIsVisible = false
    var strategyFormIsVisible = false


    var scoutFormDataIsLoaded = false
    /// This variable stores information about whether
    /// view form data for each specific team in this match
    /// has already been loaded.
    var viewFormDataIsLoaded = [String: Bool]()
    var strategyIsLoaded = false
    
    var selectedTeam = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkConnectionAndSync()
        
        matchTitle.title = "Match \(matchNumber)"
        redTeam1.setTitle(redTeams[0], for: UIControlState())
        redTeam2.setTitle(redTeams[1], for: UIControlState())
        redTeam3.setTitle(redTeams[2], for: UIControlState())
        blueTeam1.setTitle(blueTeams[0], for: UIControlState())
        blueTeam2.setTitle(blueTeams[1], for: UIControlState())
        blueTeam3.setTitle(blueTeams[2], for: UIControlState())
        
        for i in 0 ..< 3 {
            viewFormDataIsLoaded[redTeams[i]] = false
            viewFormDataIsLoaded[blueTeams[i]] = false
        }
        
        modeTabs.isHidden = true
        modeTabs.selectedSegmentIndex = -1
        
        picker.delegate = self
        picker.dataSource = self
        
        self.scrollView.addSubview(self.container)
        
        getMyTeamNumber() { teamNumber in
            if self.redTeams.contains(teamNumber) || self.blueTeams.contains(teamNumber) {
                self.modeTabs.insertSegment(withTitle: "Strategy", at: 2, animated: false)
            }
        }
        
        if Reachability.isConnectedToNetwork() {
            getCurrentRegionalKey()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func redTeam1Click(_ sender: UIButton) {
        restoreAllButtonColors()
        redTeam1.backgroundColor = UIColorFromHex("FF0000", alpha: 1)
        selectedTeam = Int((redTeam1.titleLabel?.text)!)!
        displayAndResetModeTabs()
    }
    @IBAction func redTeam2Click(_ sender: UIButton) {
        restoreAllButtonColors()
        redTeam2.backgroundColor = UIColorFromHex("FF0000", alpha: 1)
        selectedTeam = Int((redTeam2.titleLabel?.text)!)!
        displayAndResetModeTabs()
    }
    @IBAction func redTeam3Click(_ sender: UIButton) {
        restoreAllButtonColors()
        redTeam3.backgroundColor = UIColorFromHex("FF0000", alpha: 1)
        selectedTeam = Int((redTeam3.titleLabel?.text)!)!
        displayAndResetModeTabs()
    }
    @IBAction func blueTeam1Click(_ sender: UIButton) {
        restoreAllButtonColors()
        blueTeam1.backgroundColor = UIColorFromHex("007AFF", alpha: 1)
        selectedTeam = Int((blueTeam1.titleLabel?.text)!)!
        displayAndResetModeTabs()
    }
    @IBAction func blueTeam2Click(_ sender: UIButton) {
        restoreAllButtonColors()
        blueTeam2.backgroundColor = UIColorFromHex("007AFF", alpha: 1)
        selectedTeam = Int((blueTeam2.titleLabel?.text)!)!
        displayAndResetModeTabs()
    }
    @IBAction func blueTeam3Click(_ sender: UIButton) {
        restoreAllButtonColors()
        blueTeam3.backgroundColor = UIColorFromHex("007AFF", alpha: 1)
        selectedTeam = Int((blueTeam3.titleLabel?.text)!)!
        displayAndResetModeTabs()
    }

    /**
        Restores all buttons to the original
        appearance, as if they were never clicked.
     */
    func restoreAllButtonColors() {
        redTeam1.backgroundColor = UIColorFromHex("FF0000", alpha: 0.55)
        redTeam2.backgroundColor = UIColorFromHex("FF0000", alpha: 0.55)
        redTeam3.backgroundColor = UIColorFromHex("FF0000", alpha: 0.55)
        blueTeam1.backgroundColor = UIColorFromHex("007AFF", alpha: 0.6)
        blueTeam2.backgroundColor = UIColorFromHex("007AFF", alpha: 0.6)
        blueTeam3.backgroundColor = UIColorFromHex("007AFF", alpha: 0.6)
    }

    /**
        Displays modeTabs if it is hidden and sets it
        to the first value.
     */
    func displayAndResetModeTabs() {
        modeTabs.isHidden = false
        modeTabs.selectedSegmentIndex = 0

        // after setting the selectedSegmentIndex
        // property of the modetabs, we call the
        // changeModeTabs function in order to simulate
        // a user clicking on one of the tabs so that
        // the scout/view forms are hidden and
        // shown appropriately
        changeModeTabs(modeTabs)
    }

    /**
        This is called when the user selects
        a tab from modeTabs. Then it hides
        and shows the appropriate scout/view
        forms.
     */
    @IBAction func changeModeTabs(_ sender: UISegmentedControl) {
        switch modeTabs.selectedSegmentIndex {
        case 0:
            hideViewForm()
            hideStrategyForm()
            showScoutForm()
        case 1:
            hideScoutForm()
            hideStrategyForm()
            showViewForm()
        case 2:
            hideScoutForm()
            hideViewForm()
            showStrategyForm()
        default:
            break
        }
    }
    
    // MARK: - Scout Form Generation
    
    func showScoutForm() {
        if scoutFormDataIsLoaded {
            if !scoutFormIsVisible {
                for view in container.subviews {
                    // the "tag" propery of the view determines what mode tab
                    // the view belongs to. if the tag of a view in "container"
                    // equal to 0, then it is scout form input field. However,
                    // if it is equal to the currently selected team number,
                    // the subview is a view form datapoint for said team.
                    // This property is used for hiding/showing of information
                    // based on which mode tab is selected.
                    // Additionally: a tag of -1 is used for elements of the
                    // strategy form
                    if view.tag == 0 {
                        view.isHidden = false
                    }
                }
                resizeContainerHeight(self.scoutFormHeight)
            }
        } else {
            if Reachability.isConnectedToNetwork() {
                loadAndDisplayScoutForm()
            } else {
                loadAndDisplayCachedScoutForm()
            }
        }
        scoutFormIsVisible = true
    }

    /**
        Loads scout form from MorScout servers and displays
        each input item in the "container" view. After loading
        the scout form from the internet, this function caches
        said form for later use.
     */
    func loadAndDisplayScoutForm() {
        httpRequest(baseURL + "/getScoutForm", type: "POST", data: [
            "context": "match"
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
                
                self.createAndDisplaySubmitButton()
                
                let dataPointsData = NSKeyedArchiver.archivedData(withRootObject: self.dataPoints)
                storage.set(dataPointsData, forKey: "matchDataPoints")
                
                self.scoutFormDataIsLoaded = true
                self.resizeContainerHeight(self.scoutFormHeight)
                

            })
        }
    }

    /**
        Loads scout form from local cache and displays
        each input item in the "container" view. This
        function takes care of informing the user if no
        form has been cached previously.
     */
    func loadAndDisplayCachedScoutForm() {
        if let dataPointsData = storage.object(forKey: "matchDataPoints") {
            let cachedDataPoints = NSKeyedUnarchiver.unarchiveObject(with: dataPointsData as! Data) as? [DataPoint]

            if cachedDataPoints!.count == 0 {
                alert(
                    title: "No Data Found",
                    message: "In order to load the data, you need to have connected to the internet at least once.",
                    buttonText: "OK", viewController: self)
            } else {
                for cachedDataPoint in cachedDataPoints! {
                    self.createDataPoint(cachedDataPoint)
                }
                createAndDisplaySubmitButton()
                scoutFormDataIsLoaded = true
                resizeContainerHeight(self.scoutFormHeight)
            }
        } else {
            alert(
                title: "No Data Found",
                message: "In order to load the data, you need to have connected to the internet at least once.",
                buttonText: "OK", viewController: self)
        }
    }
    
    func hideScoutForm() {
        for view in self.container.subviews {
            if view.tag == 0 {
                view.isHidden = true
            }
        }
        self.scoutFormIsVisible = false
    }
    
    // MARK: - View Form Generation
    
    func showViewForm() {
        if viewFormDataIsLoaded[String(selectedTeam)] == true {
            if !viewFormIsVisible {
                for view in container.subviews {
                    if view.tag == self.selectedTeam {
                        view.isHidden = false
                    }
                }
                resizeContainerHeight(self.viewFormHeight)
            }
        } else {
            if Reachability.isConnectedToNetwork() {
                loadAndDisplayViewForm()
            } else {
                alert(
                    title: "Cannot load scouted reports",
                    message: "Unfortunately you need to be connected to the internet to view previous reports",
                    buttonText: "OK", viewController: self)
            }
        }
        self.viewFormIsVisible = true
    }

    /**
        Loads view form data of currently selected team
        from MorScout servers and displays it in
        the "container" view.
     */
    func loadAndDisplayViewForm() {
        httpRequest(baseURL+"/getMatchReports", type: "POST", data:[
            "match": String(matchNumber),
            "team": String(selectedTeam)
        ]){ responseText in
                
            let data = parseJSON(responseText)

            self.viewFormDataIsLoaded[String(self.selectedTeam)] = true
                
            DispatchQueue.main.async(execute: {
                
                self.viewFormHeight = 5
                
                if data["yourTeam"].count == 0 && data["otherTeams"].count == 0 {
                    self.displayNoReports()
                }

                if data["yourTeam"].count > 0 {
                    self.addHeaderToViewForm(
                        text: "Your Team", size: .large)
                    self.displayReports(from: data["yourTeam"])
                }

                if data["otherTeams"].count > 0 {
                    self.addHeaderToViewForm(
                        text: "Other Teams", size: .large)
                    self.displayReports(from: data["otherTeams"])
                }
                
                self.resizeContainerHeight(self.viewFormHeight)
                
            })
        }
    }

    enum HeaderSize: Int {
        case large = 1
        case medium = 2
        case small = 3
    }

    /**
        Creates a label with a line directly under it
        and adds it to the view form.
     */
    func addHeaderToViewForm(text: String, size: HeaderSize) {
        let fontSize: CGFloat
        let lineHorizontalPadding: CGFloat

        switch size {
        case .large:
            fontSize = 22.0
            lineHorizontalPadding = 40
        case .medium:
            fontSize = 19.0
            lineHorizontalPadding = 60
        case .small:
            fontSize = 17.0
            lineHorizontalPadding = 80
        }

        let label = UILabel(frame: CGRect(
            x: 10, y: self.viewFormHeight,
            width: self.view.frame.width - 20, height: 21))
        label.text = text
        label.font = UIFont(name: "Helvetica-Light", size: fontSize)
        label.textAlignment = .center
        label.tag = self.selectedTeam
        self.container.addSubview(label)
        self.viewFormHeight += label.frame.height + 5

        let line = UIView(frame: CGRect(
            x: lineHorizontalPadding, y: self.viewFormHeight,
            width: self.view.frame.width-(lineHorizontalPadding*2), height: 1))
        line.backgroundColor = UIColor.lightGray
        line.tag = self.selectedTeam
        self.container.addSubview(line)
        self.viewFormHeight += line.frame.height + 10
    }

    /**
        Displays a label in the view form that informs the user that
        no reports were made for the currently selected team.
     */
    func displayNoReports() {
        self.viewFormHeight += 25
        let label = UILabel(frame: CGRect(
            x: 10, y: self.viewFormHeight,
            width: self.view.frame.width - 20, height: 21))
        label.text = "No Reports"
        label.font = UIFont(name: "Helvetica-Light", size: 22.0)
        label.textAlignment = .center
        label.tag = self.selectedTeam
        self.container.addSubview(label)
        self.viewFormHeight += label.frame.height + 5
    }

    /**
        Loops through all the reports made and displays them
        in the view form with a key: value format.
     */
    func displayReports(from teamData: JSON) {
        for(i, subJson):(String, JSON) in teamData {

            let reportNumber = Int(i)!+1
            self.addHeaderToViewForm(
                text: "Report \(reportNumber)", size: .medium)

            for(_, subJson):(String, JSON) in subJson["data"] {

                if !subJson["value"].exists() {

                    self.addHeaderToViewForm(
                        text: subJson["name"].stringValue, size: .small)

                } else {
                    let key = UILabel(frame: CGRect(
                        x: 10, y: self.viewFormHeight,
                        width: self.view.frame.width - 160, height: 21))
                    key.text = subJson["name"].stringValue
                    key.tag = self.selectedTeam
                    self.container.addSubview(key)
                    var height = heightForView(subJson["value"].stringValue, width: 140)
                    if height == 0 {
                        height = 21
                    }
                    let value = UILabel(frame: CGRect(
                        x: self.view.frame.width-150, y: self.viewFormHeight,
                        width: 140 , height: height))
                    value.numberOfLines = 0
                    if subJson["value"].stringValue == "" {
                        value.text = "N/A"
                    } else {
                        value.text = subJson["value"].stringValue
                    }
                    value.tag = self.selectedTeam
                    self.container.addSubview(value)

                    self.viewFormHeight += value.frame.height + 5
                }
            }
        }
    }

    func hideViewForm() {
        for view in self.container.subviews {
            if view.tag != 0 {
                view.isHidden = true
            }
        }
        viewFormIsVisible = false
    }

    // MARK: - Strategy

    func showStrategyForm() {
        if strategyIsLoaded {
            if !strategyFormIsVisible {
                for view in container.subviews {
                    // A tag of -1 is used for elements of the
                    // strategy form
                    if view.tag == -1  {
                        view.isHidden = false
                    }
                }
                // the save button has an upper margin of 20 and a lower margin of 10
                resizeContainerHeight(strategyBoxHeight + 20 + strategySaveButtonHeight + 10)
            }
        } else {
            if Reachability.isConnectedToNetwork() {
                loadStrategy()
            } else {
                if let strategies = storage.object(forKey: "strategies") {
                    let strategies = strategies as! [String: [String: String]]
                    if let currentRegional = storage.string(forKey: "currentRegional") {
                        if let strategyText = strategies[currentRegional]![String(matchNumber)] {
                            let textView = UITextView(frame: CGRect(
                                x: 10, y: 5,
                                width: self.view.frame.width-20, height: strategyBoxHeight))
                            textView.text = strategyText
                            textView.font = UIFont(name: "Helvetica", size: 14.0)
                            textView.isEditable = false
                            textView.backgroundColor = UIColorFromHex("E9E9E9")
                            textView.tag = -1
                            self.container.addSubview(textView)

                            let button = UIButton(frame: CGRect(
                                x: 100, y: strategyBoxHeight + 20,
                                width: self.view.frame.width-200, height: strategySaveButtonHeight))
                            button.setTitle("Save", for: UIControlState())
                            button.backgroundColor = UIColor.lightGray
                            button.tag = -1
                            button.addTarget(self, action: #selector(MatchVC.saveStrategyClickDisabled(_:)), for: .touchUpInside)
                            self.container.addSubview(button)

                            resizeContainerHeight(strategyBoxHeight + 20 + button.frame.height + 10)
                            strategyIsLoaded = true
                        }
                    }
                } else {
                    alert(
                        title: "No Data Found",
                        message: "In order to load the data, you need to have connected to the internet at least once.",
                        buttonText: "OK", viewController: self)
                }
            }
        }
        strategyFormIsVisible = true
    }
    
    func loadStrategy() {
        httpRequest(baseURL + "/getMatchStrategy", type: "POST", data: [
            "match": String(matchNumber)
        ]) { responseText in
            let strategy = parseJSON(responseText)
            var strategyText = strategy["strategy"].stringValue
            
            if strategyText == "null" {
                strategyText = ""
            }
            
            if let currentRegional = storage.string(forKey: "currentRegional") {
                if let strategies = storage.object(forKey: "strategies"){
                    var strategies = strategies as! [String: [String: String]]
                    if let _ = strategies[currentRegional] {
                        strategies[currentRegional]![String(self.matchNumber)] = strategyText
                    } else {
                        strategies[currentRegional] = [String(self.matchNumber): strategyText]
                    }
                    storage.set(strategies, forKey: "strategies")
                } else {
                    var strategies = [String: [String: String]]()
                    strategies[currentRegional] = [String(self.matchNumber): strategyText]
                    storage.set(strategies, forKey: "strategies")
                }
            }
            
            DispatchQueue.main.async(execute: {
                let textView = UITextView(frame: CGRect(x: 10, y: 5, width: self.view.frame.width-20, height: self.strategyBoxHeight))
                textView.text = strategyText
                textView.font = UIFont(name: "Helvetica", size: 14.0)
                textView.tag = -1
                self.container.addSubview(textView)
                
                let button = UIButton(frame: CGRect(x: 100, y: self.strategyBoxHeight + 20, width: self.view.frame.width-200, height: 30))
                button.setTitle("Save", for: UIControlState())
                button.backgroundColor = UIColor.orange
                button.tag = -1
                button.addTarget(self, action: #selector(MatchVC.saveStrategyClick(_:)), for: .touchUpInside)
                self.container.addSubview(button)
                
                self.resizeContainerHeight(self.strategyBoxHeight + 20 + button.frame.height + 10)
                self.strategyIsLoaded = true
            })
        }
    }
    
    func hideStrategyForm() {
        for view in self.container.subviews {
            if view.tag == -1 {
                view.isHidden = true
            }
        }
        strategyFormIsVisible = false
    }
    
    func saveStrategyClick(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            var textViewText = ""
            for i in 0 ..< self.container.subviews.count {
                let view = self.container.subviews[i]
                if view.tag == -1 {
                    let textView = view as! UITextView
                    textViewText = textView.text
                    break
                }
            }
            
            httpRequest(baseURL + "/setMatchStrategy", type: "POST", data: [
                "match": String(self.matchNumber),
                "strategy": textViewText
            ]) { responseText in
                if responseText == "success" {
                    alert(
                        title: "Success",
                        message: "The match strategy was successfully updated",
                        buttonText: "OK", viewController: self)
                }
            }
        } else {
            alert(
                title: "No Internet",
                message: "Cannot edit strategy when internet connection is not available.",
                buttonText: "OK", viewController: self)
        }
    }
    
    func saveStrategyClickDisabled(_ sender: UIButton) {
        alert(
            title: "No Internet",
            message: "Cannot edit strategy when internet connection is not available.",
            buttonText: "OK", viewController: self)
    }
    
    // MARK: - Misc

    /**
        Creates the UI element that corresponds with the type of
        data point provided to the function, and then appends it
        to the "container".
     */
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
            }else{
                numberField = UITextField(frame: CGRect(x: label.intrinsicContentSize.width+15, y: self.scoutFormHeight, width: 40, height: 29))
            }

            stepper.numberField = numberField
            stepper.numberField?.text = String(dataPoint.start)
            stepper.numberField?.keyboardType = .numberPad
            stepper.maximumValue = Double(dataPoint.max)
            stepper.minimumValue = Double(dataPoint.min)
            stepper.addTarget(self, action: #selector(MatchVC.stepperValueChanged(_:)), for: .valueChanged)

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

    /**
        This function is called when the user increases
        or decreases the value of a number stepper and
        then updates the textfield that displays the
        stepper's value.
     */
    func stepperValueChanged(_ sender: UIStepper) {
        let sender = sender as! NumberStepper
        sender.numberField?.text = Int(sender.value).description
    }

    /**
        Creates a UIToolbar and its done button
        and returns them as a tuple.
     */
    func createToolbar() -> (UIToolbar, DoneButton) {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = DoneButton(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MatchVC.clickedDoneButton(_:)))
        toolBar.setItems([flexSpace, doneButton], animated: true)
        return (toolBar, doneButton)
    }

    func resizeContainerHeight(_ height: CGFloat) {
        self.container.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: height)
        self.scrollView.contentSize = self.container.bounds.size
    }

    /**
        Creates a submit button and appends it to
        the "container".
     */
    func createAndDisplaySubmitButton() {
        self.scoutFormHeight += 10
        let button = UIButton(frame: CGRect(x: 100, y: self.scoutFormHeight, width: self.view.frame.width-200, height: 30))
        button.setTitle("Submit", for: UIControlState())
        button.backgroundColor = UIColor.orange
        button.addTarget(self, action: #selector(MatchVC.submitFormClick(_:)), for: .touchUpInside)
        self.scoutFormHeight += button.frame.height + 15
        self.container.addSubview(button)
    }

    /**
        This function is called when the "submit" button
        has been clicked.
     */
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
            
            let data = [
                "data": jsonStringDataArray,
                "team": String(selectedTeam),
                "context": "match",
                "match": String(matchNumber),
                "regional": storage.string(forKey: "currentRegional")!
            ]
            
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
                alert(
                    title: "Submission saved ",
                    message: "You are currently not connected to the internet so we saved your submission locally. It will be sent to the server once an internet connection is established.",
                    buttonText: "OK", viewController: self)
            }
            
            
        }
    }
    
    func sendSubmission(_ data: [String: String]) {
        httpRequest(baseURL + "/submitReport", type: "POST", data: data) { responseText in
            if responseText != "fail" {
                alert(
                    title: "Success",
                    message: "You have successfully submitted the report.",
                    buttonText: "OK", viewController: self)
            } else {
                alert(
                    title: "Oops",
                    message: "Something went wrong :(",
                    buttonText: "OK", viewController: self)
            }
        }
    }

    /**
        This function is called when the "done" button
        is pressed on the dropdown toolbar.
     */
    func clickedDoneButton(_ sender: UIBarButtonItem) {
        let sender = sender as! DoneButton
        
        if let textField = sender.textField {
            textField.resignFirstResponder()
        }
        
        if let textView = sender.textView {
            textView.resignFirstResponder()
        }
    }

    /**
        Gets the team number of the currently logged in
        user and supplies it in a callback
     */
    func getMyTeamNumber(_ cb: @escaping (_ teamNumber: String) -> Void) {
        if let savedTeamNumber = storage.string(forKey: "team_number") {
            cb(savedTeamNumber)
        }else{
            httpRequest(morTeamURL + "/teams/current/number", type: "GET") { responseText in
                storage.set(responseText, forKey: "team_number")
                cb(responseText)
            }
        }
    }
    
}

extension MatchVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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

extension MatchVC: UITextFieldDelegate {
    
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

