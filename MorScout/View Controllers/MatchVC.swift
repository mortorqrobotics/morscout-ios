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
    var container = UIView()
    var scoutTopMargin: CGFloat = 5
    var viewTopMargin: CGFloat = 5
    let strategyBoxHeight: CGFloat = 100
    
    var picker: DropdownPicker = DropdownPicker()
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
    var myTeam = ""
    
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
        
        getTeamNumber() {
            if self.redTeams.contains(self.myTeam) || self.blueTeams.contains(self.myTeam) {
                self.modeTabs.insertSegment(withTitle: "Strategy", at: 2, animated: false)
            }
        }
        
        if Reachability.isConnectedToNetwork() {
            getCurrentRegionalKey()
        }
        
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
    
    @IBAction func redTeam1Click(_ sender: UIButton) {
        restoreAllButtonColors()
        redTeam1.backgroundColor = UIColorFromHex("FF0000", alpha: 1)
        selectedTeam = Int((redTeam1.titleLabel?.text)!)!
        modeTabs.isHidden = false
        modeTabs.selectedSegmentIndex = 0
        changeModeTabs(modeTabs)
    }
    @IBAction func redTeam2Click(_ sender: UIButton) {
        restoreAllButtonColors()
        redTeam2.backgroundColor = UIColorFromHex("FF0000", alpha: 1)
        selectedTeam = Int((redTeam2.titleLabel?.text)!)!
        modeTabs.isHidden = false
        modeTabs.selectedSegmentIndex = 0
        changeModeTabs(modeTabs)
    }
    @IBAction func redTeam3Click(_ sender: UIButton) {
        restoreAllButtonColors()
        redTeam3.backgroundColor = UIColorFromHex("FF0000", alpha: 1)
        selectedTeam = Int((redTeam3.titleLabel?.text)!)!
        modeTabs.isHidden = false
        modeTabs.selectedSegmentIndex = 0
        changeModeTabs(modeTabs)
    }
    @IBAction func blueTeam1Click(_ sender: UIButton) {
        restoreAllButtonColors()
        blueTeam1.backgroundColor = UIColorFromHex("007AFF", alpha: 1)
        selectedTeam = Int((blueTeam1.titleLabel?.text)!)!
        modeTabs.isHidden = false
        modeTabs.selectedSegmentIndex = 0
        changeModeTabs(modeTabs)
    }
    @IBAction func blueTeam2Click(_ sender: UIButton) {
        restoreAllButtonColors()
        blueTeam2.backgroundColor = UIColorFromHex("007AFF", alpha: 1)
        selectedTeam = Int((blueTeam2.titleLabel?.text)!)!
        modeTabs.isHidden = false
        modeTabs.selectedSegmentIndex = 0
        changeModeTabs(modeTabs)
    }
    @IBAction func blueTeam3Click(_ sender: UIButton) {
        restoreAllButtonColors()
        blueTeam3.backgroundColor = UIColorFromHex("007AFF", alpha: 1)
        selectedTeam = Int((blueTeam3.titleLabel?.text)!)!
        modeTabs.isHidden = false
        modeTabs.selectedSegmentIndex = 0
        changeModeTabs(modeTabs)
    }
    
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
    
    func getCurrentRegionalKey() {
        httpRequest(baseURL+"/getCurrentRegionalInfo", type: "POST"){
            responseText in
            
            let regionalInfo = parseJSON(responseText)
            if !regionalInfo["Errors"].exists() {
                let currentRegionalKey = String(describing: regionalInfo["key"])
                storage.setValue(currentRegionalKey, forKey: "currentRegional")
            }
        }
    }
    
    // MARK: - Scout Form Generation
    
    func showScoutForm() {
        if scoutFormDataIsLoaded {
            if !scoutFormIsVisible {
                for view in container.subviews {
                    if view.tag == 0 {
                        view.isHidden = false
                    }
                }
                resizeContainer(self.scoutTopMargin)
            }
        }else{
            if Reachability.isConnectedToNetwork() {
                loadScoutForm()
            }else{
                if let dataPointsData = storage.object(forKey: "matchDataPoints") {
                    let cachedDataPoints = NSKeyedUnarchiver.unarchiveObject(with: dataPointsData as! Data) as? [DataPoint]
                    
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
            DispatchQueue.main.async(execute: {
                
                for(i, subJson):(String, JSON) in formData {
                    let type = subJson["type"].stringValue
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
                
                let dataPointsData = NSKeyedArchiver.archivedData(withRootObject: self.dataPoints)
                storage.set(dataPointsData, forKey: "matchDataPoints")
                
                self.scoutFormDataIsLoaded = true
                
                self.resizeContainer(self.scoutTopMargin)
                

            })
        }
    }
    
    func retrieveScoutFormFromCache() {
        if let dataPointsData = storage.object(forKey: "matchDataPoints") {
            let cachedDataPoints = NSKeyedUnarchiver.unarchiveObject(with: dataPointsData as! Data) as? [DataPoint]
            
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

                
            DispatchQueue.main.async(execute: {
                
                self.viewTopMargin = 5
                
                if data["yourTeam"].count == 0 && data["otherTeams"].count == 0 {
                    self.viewTopMargin += 25
                    let label = UILabel(frame: CGRect(x: 10, y: self.viewTopMargin, width: self.view.frame.width - 20, height: 21))
                    label.text = "No Reports"
                    label.font = UIFont(name: "Helvetica-Light", size: 22.0)
                    label.textAlignment = .center
                    label.tag = self.selectedTeam
                    self.container.addSubview(label)
                    self.viewTopMargin += label.frame.height + 5
                }
    
                if data["yourTeam"].count != 0 {
                    let label = UILabel(frame: CGRect(x: 10, y: self.viewTopMargin, width: self.view.frame.width - 20, height: 21))
                    label.text = "Your Team"
                    label.font = UIFont(name: "Helvetica-Light", size: 22.0)
                    label.textAlignment = .center
                    label.tag = self.selectedTeam
                    self.container.addSubview(label)
                    self.viewTopMargin += label.frame.height + 5
                    
                    let line = UIView(frame: CGRect(x: 40, y: self.viewTopMargin, width: self.view.frame.width-80, height: 1))
                    line.backgroundColor = UIColor.lightGray
                    line.tag = self.selectedTeam
                    self.container.addSubview(line)
                    self.viewTopMargin += line.frame.height + 10
                    
                    for(i, subJson):(String, JSON) in data["yourTeam"] {
                        let reportNumber = Int(i)!+1
                        let label = UILabel(frame: CGRect(x: 10, y: self.viewTopMargin, width: self.view.frame.width - 20, height: 21))
                        label.text = "Report \(reportNumber)"
                        label.font = UIFont(name: "Helvetica-Light", size: 21.0)
                        label.textAlignment = .center
                        label.tag = self.selectedTeam
                        self.container.addSubview(label)
                        self.viewTopMargin += label.frame.height + 5
                        
                        let line = UIView(frame: CGRect(x: 60, y: self.viewTopMargin, width: self.view.frame.width-120, height: 1))
                        line.backgroundColor = UIColor.lightGray
                        line.tag = self.selectedTeam
                        self.container.addSubview(line)
                        self.viewTopMargin += line.frame.height + 10
                        
                        for(_, subJson):(String, JSON) in subJson["data"] {
                            if subJson["value"].stringValue == "null" {
                                let label = UILabel(frame: CGRect(x: 10, y: self.viewTopMargin, width: self.view.frame.width - 20, height: 21))
                                label.text = subJson["name"].stringValue
                                label.font = UIFont(name: "Helvetica-Light", size: 20.0)
                                label.textAlignment = .center
                                label.tag = self.selectedTeam
                                self.container.addSubview(label)
                                self.viewTopMargin += label.frame.height + 5
                                
                                let line = UIView(frame: CGRect(x: 80, y: self.viewTopMargin, width: self.view.frame.width-160, height: 1))
                                line.backgroundColor = UIColor.lightGray
                                line.tag = self.selectedTeam
                                self.container.addSubview(line)
                                self.viewTopMargin += line.frame.height + 10
                            }else{
                                let key = UILabel(frame: CGRect(x: 10, y: self.viewTopMargin, width: self.view.frame.width - 160, height: 21))
                                key.text = subJson["name"].stringValue
                                key.tag = self.selectedTeam
                                self.container.addSubview(key)
                                var height = heightForView(subJson["value"].stringValue, width: 140)
                                if height == 0 {
                                    height = 21
                                }
                                let value = UILabel(frame: CGRect(x: self.view.frame.width-150, y: self.viewTopMargin, width: 140 , height: height))
                                value.numberOfLines = 0
                                if subJson["value"].stringValue == "" {
                                    value.text = "N/A"
                                }else{
                                    value.text = subJson["value"].stringValue
                                }
                                value.tag = self.selectedTeam
                                self.container.addSubview(value)
                                
                                self.viewTopMargin += value.frame.height + 5
                            }
                        }
                    }
                }
                    
                if data["otherTeams"].count != 0 {
                    
                    let label = UILabel(frame: CGRect(x: 10, y: self.viewTopMargin, width: self.view.frame.width - 20, height: 21))
                    label.text = "Other Teams"
                    label.font = UIFont(name: "Helvetica-Light", size: 22.0)
                    label.textAlignment = .center
                    label.tag = self.selectedTeam
                    self.container.addSubview(label)
                    self.viewTopMargin += label.frame.height + 5
                    
                    let line = UIView(frame: CGRect(x: 40, y: self.viewTopMargin, width: self.view.frame.width-80, height: 1))
                    line.backgroundColor = UIColor.lightGray
                    line.tag = self.selectedTeam
                    self.container.addSubview(line)
                    self.viewTopMargin += line.frame.height + 10
                    
                    
                    for(i, subJson):(String, JSON) in data["otherTeams"] {
                        let reportNumber = Int(i)!+1
                        let label = UILabel(frame: CGRect(x: 10, y: self.viewTopMargin, width: self.view.frame.width - 20, height: 21))
                        label.text = "Report \(reportNumber)"
                        label.font = UIFont(name: "Helvetica-Light", size: 21.0)
                        label.textAlignment = .center
                        label.tag = self.selectedTeam
                        self.container.addSubview(label)
                        self.viewTopMargin += label.frame.height + 5
                        
                        let line = UIView(frame: CGRect(x: 60, y: self.viewTopMargin, width: self.view.frame.width-120, height: 1))
                        line.backgroundColor = UIColor.lightGray
                        line.tag = self.selectedTeam
                        self.container.addSubview(line)
                        self.viewTopMargin += line.frame.height + 10
                        
                        for(_, subJson):(String, JSON) in subJson["data"] {
                            if subJson["value"].stringValue == "null" {
                                let label = UILabel(frame: CGRect(x: 10, y: self.viewTopMargin, width: self.view.frame.width - 20, height: 21))
                                label.text = subJson["name"].stringValue
                                label.font = UIFont(name: "Helvetica-Light", size: 20.0)
                                label.textAlignment = .center
                                label.tag = self.selectedTeam
                                self.container.addSubview(label)
                                self.viewTopMargin += label.frame.height + 5
                                
                                let line = UIView(frame: CGRect(x: 80, y: self.viewTopMargin, width: self.view.frame.width-160, height: 1))
                                line.backgroundColor = UIColor.lightGray
                                line.tag = self.selectedTeam
                                self.container.addSubview(line)
                                self.viewTopMargin += line.frame.height + 10
                            }else{
                                let key = UILabel(frame: CGRect(x: 10, y: self.viewTopMargin, width: self.view.frame.width - 160, height: 21))
                                key.text = subJson["name"].stringValue
                                key.tag = self.selectedTeam
                                self.container.addSubview(key)
                                var height = heightForView(subJson["value"].stringValue, width: 140)
                                if height == 0 {
                                    height = 21
                                }
                                let value = UILabel(frame: CGRect(x: self.view.frame.width-150, y: self.viewTopMargin, width: 140 , height: height))
                                value.numberOfLines = 0
                                if subJson["value"].stringValue == "" {
                                    value.text = "N/A"
                                }else{
                                    value.text = subJson["value"].stringValue
                                }
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
                    if view.tag == -1  {
                        view.isHidden = false
                    }
                }
                resizeContainer(strategyBoxHeight + 20 + 30 + 10)
            }
        }else{
            if Reachability.isConnectedToNetwork() {
                loadStrategy()
            }else{
                if let strategies = storage.object(forKey: "strategies") {
                    let strategies = strategies as! [String: [String: String]]
                    if let currentRegional = storage.string(forKey: "currentRegional") {
                        if let strategyText = strategies[currentRegional]![String(matchNumber)] {
                            let textView = UITextView(frame: CGRect(x: 10, y: 5, width: self.view.frame.width-20, height: strategyBoxHeight))
                            textView.text = strategyText
                            textView.font = UIFont(name: "Helvetica", size: 14.0)
                            textView.isEditable = false
                            textView.backgroundColor = UIColorFromHex("E9E9E9")
                            textView.tag = -1
                            self.container.addSubview(textView)
                            
                            let button = UIButton(frame: CGRect(x: 100, y: strategyBoxHeight + 20, width: self.view.frame.width-200, height: 30))
                            button.setTitle("Save", for: UIControlState())
                            button.backgroundColor = UIColor.lightGray
                            button.tag = -1
                            button.addTarget(self, action: #selector(MatchVC.saveStrategyClickDisabled(_:)), for: .touchUpInside)
                            self.container.addSubview(button)

                            resizeContainer(strategyBoxHeight + 20 + button.frame.height + 10)
                            strategyIsLoaded = true
                        }
                    }
                }else{
                    alert(title: "No Data Found", message: "In order to load the data, you need to have connected to the internet at least once.", buttonText: "OK", viewController: self)
                }
            }
        }
        strategyFormIsVisible = true
    }
    
    func loadStrategy() {
        httpRequest(baseURL+"/getMatchStrategy", type: "POST", data: ["match": String(matchNumber)]) {responseText in
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
                    }else{
                        strategies[currentRegional] = [String(self.matchNumber): strategyText]
                    }
                    storage.set(strategies, forKey: "strategies")
                }else{
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
                
                self.resizeContainer(self.strategyBoxHeight + 20 + button.frame.height + 10)
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
            
            httpRequest(baseURL+"/setMatchStrategy", type: "POST", data: ["match": String(self.matchNumber), "strategy": textViewText]) { responseText in
                if responseText == "success" {
                    alert(title: "Success", message: "The match strategy was successfully updated", buttonText: "OK", viewController: self)
                }
            }
        }else{
            alert(title: "No Internet", message: "Cannot edit strategy when internet connection is not available.", buttonText: "OK", viewController: self)
        }
    }
    
    func saveStrategyClickDisabled(_ sender: UIButton) {
        alert(title: "No Internet", message: "Cannot edit strategy when internet connection is not available.", buttonText: "OK", viewController: self)
    }
    
    // MARK: - Misc
    
    func createDataPoint(_ dataPoint: DataPoint) {
        
        //the tags for scout form elements are being set to 0
        
        let type = String(describing: Mirror(reflecting: dataPoint).subjectType)
        
        if type == "Label" {
            let dataPoint = dataPoint as! Label
            
            let label = UILabel(frame: CGRect(x: 10, y: self.scoutTopMargin, width: self.view.frame.width-20, height: 26))
            label.text = dataPoint.name
            label.font = UIFont(name: "Helvetica-Light", size: 22.0)
            label.textAlignment = .center
            label.tag = 0
            self.container.addSubview(label)
            self.scoutTopMargin += label.frame.height + 5
            
            let line = UIView(frame: CGRect(x: 80, y: self.scoutTopMargin, width: self.view.frame.width-160, height: 1))
            line.backgroundColor = UIColor.lightGray
            line.tag = 0
            self.container.addSubview(line)
            self.scoutTopMargin += line.frame.height + 10
            
        }else if type == "TextBox" {
            let dataPoint = dataPoint as! TextBox
            
            let label = UILabel(frame: CGRect(x: 10, y: self.scoutTopMargin, width: self.view.frame.width-20, height: 21))
            label.text = dataPoint.name
            label.font = UIFont(name: "Helvetica-Light", size: 17.0)
            label.textColor = UIColor.black
            label.tag = 0
            self.container.addSubview(label)
            self.scoutTopMargin += label.frame.height + 5
            
            let textbox = UITextView(frame: CGRect(x: 10, y: self.scoutTopMargin, width: self.view.frame.width-20, height: 90))
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
            self.scoutTopMargin += textbox.frame.height + 10
            
        }else if type == "Dropdown" {
            let dataPoint = dataPoint as! Dropdown
            
            let options = dataPoint.options
            
            self.pickerLists[dataPoint.name] = options
            
            let label = UILabel(frame: CGRect(x: 10, y: self.scoutTopMargin, width: self.view.frame.width-20, height: 21))
            label.text = dataPoint.name + ":"
            label.tag = 0
            self.container.addSubview(label)
            
            let textField = DropdownTextField(frame: CGRect(x: label.intrinsicContentSize.width+15, y: self.scoutTopMargin, width: self.view.frame.width-20-label.intrinsicContentSize.width-15, height: 21))
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
            
            let label = UILabel(frame: CGRect(x: 10, y: self.scoutTopMargin, width: self.view.frame.width-94-45, height: 29))
            label.text = dataPoint.name + ":"
            let stepper = NumberStepper(frame: CGRect(x: self.view.frame.width - 105, y: self.scoutTopMargin, width: 0, height: 0))
            let numberField: UITextField
            if label.intrinsicContentSize.width > (self.view.frame.width-94-50) {
                numberField = UITextField(frame: CGRect(x: self.view.frame.width-94-35, y: self.scoutTopMargin, width: 40, height: 29))
            }else{
                numberField = UITextField(frame: CGRect(x: label.intrinsicContentSize.width+15, y: self.scoutTopMargin, width: 40, height: 29))
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
            self.scoutTopMargin += label.frame.height + 10
            
        }else if type == "Checkbox" {
            let dataPoint = dataPoint as! Checkbox
            
            let label = UILabel(frame: CGRect(x: 10, y: self.scoutTopMargin, width: self.view.frame.width-54-20, height: 31))
            label.text = dataPoint.name
            label.tag = 0
            self.container.addSubview(label)
            
            let check = UISwitch(frame: CGRect(x: self.view.frame.width-65, y: self.scoutTopMargin, width: 0, height: 0))
            check.tintColor = UIColorFromHex("FF8900")
            check.onTintColor = UIColorFromHex("FF8900")
            check.tag = 0
            self.container.addSubview(check)
            
            self.scoutTopMargin += label.frame.height + 10
            
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
        let doneButton = DoneButton(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MatchVC.clickedDoneButton(_:)))
        toolBar.setItems([flexSpace, doneButton], animated: true)
        return (toolBar, doneButton)
    }
    
    func resizeContainer(_ margin: CGFloat) {
        self.container.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: margin)
        self.scrollView.contentSize = self.container.bounds.size
    }
    
    func createSubmitButton() {
        self.scoutTopMargin += 10
        let button = UIButton(frame: CGRect(x: 100, y: self.scoutTopMargin, width: self.view.frame.width-200, height: 30))
        button.setTitle("Submit", for: UIControlState())
        button.backgroundColor = UIColor.orange
        button.addTarget(self, action: #selector(MatchVC.submitFormClick(_:)), for: .touchUpInside)
        self.scoutTopMargin += button.frame.height + 5
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
                    }else if type == "UITextView" {
                        let textViewLabel = views[i-1] as! UILabel
                        let textView = views[i] as! UITextView
                        jsonStringDataArray += "{\"name\": \"\(escape(textViewLabel.text!))\", \"value\": \"\(escape(textView.text!))\"},"
                    }else if type == "DropdownTextField" {
                        let textField = views[i] as! DropdownTextField
                        if textField.text?.contains("▾") == true {
                            textField.text = String(describing: textField.text?.characters.dropLast(2))
                        }
                        jsonStringDataArray += "{\"name\": \"\(escape(textField.dropdown!))\", \"value\": \"\(escape(textField.text!))\"},"
                    }else if type == "NumberStepper" {
                        let stepperLabel = views[i-2] as! UILabel
                        let stepperTextField = views[i-1] as! UITextField
                        jsonStringDataArray += "{\"name\": \"\(escape(String(stepperLabel.text!.characters.dropLast())))\", \"value\": \"\(stepperTextField.text!)\"},"
                    }else if type == "UISwitch" {
                        let checkLabel = views[i-1] as! UILabel
                        let check = views[i] as! UISwitch
                        jsonStringDataArray += "{\"name\": \"\(escape(checkLabel.text!))\", \"value\": \"\(check.isOn)\"},"
                    }
                }
            }
            jsonStringDataArray = String(jsonStringDataArray.characters.dropLast())
            jsonStringDataArray += "]"
            
            let data = ["data": jsonStringDataArray, "team": String(selectedTeam), "context": "match", "match": String(matchNumber), "regional": storage.string(forKey: "currentRegional")!]
            
            if Reachability.isConnectedToNetwork() {
                sendSubmission(data)
            }else{
                if let savedReports = storage.array(forKey: "savedReports") {
                    var newSavedReports = savedReports
                    newSavedReports.append(data)
                    storage.set(newSavedReports, forKey: "savedReports")
                }else{
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
            }else{
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
    
    func getTeamNumber(_ cb: @escaping () -> Void) {
        if let savedTeamNumber = storage.string(forKey: "team_number") {
            self.myTeam = savedTeamNumber
            cb()
        }else{
            httpRequest(morTeamURL + "/teams/current/number", type: "GET") { responseText in
                self.myTeam = responseText
                storage.set(self.myTeam, forKey: "team_number")
                cb()
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

