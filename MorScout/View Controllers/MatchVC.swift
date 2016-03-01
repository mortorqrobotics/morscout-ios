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
    var topMargin: CGFloat = 5
    
    var picker: DropdownPicker = DropdownPicker()
    
    var pickerLists = [String: Array<String>]()
    
    override func viewDidLoad() {
        matchTitle.title = "Match \(matchNumber)"
        redTeam1.setTitle(redTeams[0], forState: .Normal)
        redTeam2.setTitle(redTeams[1], forState: .Normal)
        redTeam3.setTitle(redTeams[2], forState: .Normal)
        blueTeam1.setTitle(blueTeams[0], forState: .Normal)
        blueTeam2.setTitle(blueTeams[1], forState: .Normal)
        blueTeam3.setTitle(blueTeams[2], forState: .Normal)
        
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
        modeTabs.hidden = false
    }
    @IBAction func redTeam2Click(sender: UIButton) {
        restoreAllButtonColors()
        redTeam2.backgroundColor = UIColorFromHex("FF0000", alpha: 1)
        modeTabs.hidden = false
    }
    @IBAction func redTeam3Click(sender: UIButton) {
        restoreAllButtonColors()
        redTeam3.backgroundColor = UIColorFromHex("FF0000", alpha: 1)
        modeTabs.hidden = false
    }
    @IBAction func blueTeam1Click(sender: UIButton) {
        restoreAllButtonColors()
        blueTeam1.backgroundColor = UIColorFromHex("007AFF", alpha: 1)
        modeTabs.hidden = false
    }
    @IBAction func blueTeam2Click(sender: UIButton) {
        restoreAllButtonColors()
        blueTeam2.backgroundColor = UIColorFromHex("007AFF", alpha: 1)
        modeTabs.hidden = false
    }
    @IBAction func blueTeam3Click(sender: UIButton) {
        restoreAllButtonColors()
        blueTeam3.backgroundColor = UIColorFromHex("007AFF", alpha: 1)
        modeTabs.hidden = false
    }
    
    @IBAction func changeModeTabs(sender: UISegmentedControl) {
        switch modeTabs.selectedSegmentIndex {
        case 0:
            clearContainer()
            loadScoutForm()
        case 1:
            clearContainer()
            loadViewForm()
        case 2:
            clearContainer()
        default:
            clearContainer()
        }
    }
    
    func loadScoutForm() {
        httpRequest(baseURL+"/getScoutForm", type: "POST", data: ["context": "match"]) {responseText in
            let formData = parseJSON(responseText)
            dispatch_async(dispatch_get_main_queue(),{
                
                for(_, subJson):(String, JSON) in formData {
                    self.createDataPoint(subJson)
                }
                
                // I don't know why the x-distance is 4 but it works
                self.container.frame = CGRectMake(4, 0, self.view.frame.width, self.topMargin)
                self.scrollView.contentSize = self.container.bounds.size

            })
        }
    }
    
    func loadViewForm() {
        
    }
    
    func clearContainer() {
        for view in self.container.subviews {
            view.removeFromSuperview()
        }
        topMargin = 5
    }
    
    func createDataPoint(json: JSON) {
        let type = String(json["type"])
        //let types = ["dropdown", "checkbox", "radio", "text", "number", "label"]
        if type == "label" {
            
            let label = UILabel(frame: CGRectMake(10, self.topMargin, self.view.frame.width-20, 26))
            label.text = String(json["name"])
            label.font = UIFont(name: "Helvetica-Light", size: 22.0)
            label.textAlignment = .Center
            self.container.addSubview(label)
            self.topMargin += label.frame.height + 5
            
            let line = UIView(frame: CGRectMake(80, self.topMargin, self.view.frame.width-160, 1))
            line.backgroundColor = UIColor.lightGrayColor()
            self.container.addSubview(line)
            self.topMargin += line.frame.height + 10
            
        }else if type == "text" {
            
            let label = UILabel(frame: CGRectMake(10, self.topMargin, self.view.frame.width-20, 21))
            label.text = String(json["name"])
            label.font = UIFont(name: "Helvetica-Light", size: 17.0)
            label.textColor = UIColor.blackColor()
            self.container.addSubview(label)
            self.topMargin += label.frame.height + 5
            
            let textbox = UITextView(frame: CGRectMake(10, self.topMargin, self.view.frame.width-20, 90))
            textbox.font = UIFont.systemFontOfSize(15)
            textbox.autocorrectionType = UITextAutocorrectionType.No
            textbox.keyboardType = UIKeyboardType.Default
            textbox.returnKeyType = UIReturnKeyType.Done
            self.container.addSubview(textbox)
            self.topMargin += textbox.frame.height + 10
            
        }else if type == "dropdown" || type == "radio" {
            
            var options: [String] = []
            for (_, subJson):(String, JSON) in json["options"] {
                options.append(String(subJson))
            }
            
            self.pickerLists[String(json["name"])] = options
            
            let textField = DropdownTextField(frame: CGRectMake(10, self.topMargin, self.view.frame.width-20, 21))
            textField.dropdown = String(json["name"])
            textField.placeholder = String(json["name"])
            textField.delegate = self
            self.container.addSubview(textField)
            self.topMargin += textField.frame.height + 15

        }else if type == "number" {
            
            let label = UILabel(frame: CGRectMake(10, self.topMargin, self.view.frame.width-20, 29))
            let stepper = NumberStepper(frame: CGRectMake(self.view.frame.width - 105, self.topMargin, 0, 0))
            let numberField = UITextField(frame: CGRectMake(200, self.topMargin, 40, 29))
            stepper.numberField = numberField
            stepper.numberField?.text = String(json["start"])
            stepper.numberField?.keyboardType = .NumberPad
            stepper.maximumValue = Double(String(json["max"]))!
            stepper.minimumValue = Double(String(json["min"]))!
            label.text = String(json["name"]) + ":"
            stepper.addTarget(self, action: "stepperValueChanged:", forControlEvents: .ValueChanged)
            self.container.addSubview(label)
            self.container.addSubview(stepper.numberField!)
            self.container.addSubview(stepper)
            self.topMargin += label.frame.height + 10
            
        }else if type == "checkbox" {
            let label = UILabel(frame: CGRectMake(10, self.topMargin, self.view.frame.width-20, 21))
            label.text = String(json["name"])
            self.container.addSubview(label)
            self.topMargin += label.frame.height + 10
        }
    }
    
    func stepperValueChanged(sender: UIStepper) {
        let sender = sender as! NumberStepper
        sender.numberField?.text = Int(sender.value).description
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
        textField.inputView = self.picker
        
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let doneButton = DoneButton(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "clickedDoneButton:")
        doneButton.textField = textField
        toolBar.setItems([flexSpace, doneButton], animated: true)
        textField.inputAccessoryView = toolBar
        
        self.picker.dropdown = textField.dropdown
        self.picker.reloadAllComponents()
        self.picker.selectRow(0, inComponent: 0, animated: false)
    }
    
    func clickedDoneButton(sender: UIBarButtonItem) {
        let sender = sender as! DoneButton
        sender.textField!.resignFirstResponder()
    }

}

