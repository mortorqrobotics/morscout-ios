//
//  Util.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/8/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Kingfisher

/// this variable stores local data for this application (e.g. user data)
let storage = UserDefaults.standard

/// base MorScout URL for requests to the MorScout server
let baseURL = "https://www.scout.morteam.com"

/// base MorTeam URL for requests to the MorTeam server
/// (typically for account/team related requests)
let morTeamURL = "https://www.morteam.com/api"

// modifies all kingfisher requests to send session cookie
let modifier = AnyModifier { request in
    var r = request
    r.addValue("connect.sid=\(storage.string(forKey: "connect.sid")!)", forHTTPHeaderField: "Cookie")
    return r
}

/**
    This can be used to get a color using a known hex value.
 */
func UIColorFromHex(_ hex: String) -> UIColor {
    var hex = hex
    
    
    if hex.hasPrefix("#") {
        hex = hex.substring(with: (hex.characters.index(hex.startIndex, offsetBy: 1) ..< hex.endIndex))
    }
    
    //get each color
    let r = hex.substring(with: (hex.startIndex ..< hex.characters.index(hex.startIndex, offsetBy: 2)))
    let g = hex.substring(with: (hex.characters.index(hex.startIndex, offsetBy: 2) ..< hex.characters.index(hex.startIndex, offsetBy: 4)))
    let b = hex.substring(with: (hex.characters.index(hex.startIndex, offsetBy: 4) ..< hex.characters.index(hex.startIndex, offsetBy: 6)))
    
    //convert to decimal
    let rd = UInt8(strtoul(r, nil, 16))
    let gd = UInt8(strtoul(g, nil, 16))
    let bd = UInt8(strtoul(b, nil, 16))
    
    //convert to floats from UInt8
    let rdFloat = CGFloat(rd)
    let gdFloat = CGFloat(gd)
    let bdFloat = CGFloat(bd)
    
    return UIColor(red: rdFloat/255, green: gdFloat/255, blue: bdFloat/255, alpha: 1)
}

/**
    This can be used to get a color using a known hex value and alpha value.
 */
func UIColorFromHex(_ hex: String, alpha: Double) -> UIColor {
    var hex = hex
    if hex.hasPrefix("#") {
        hex = hex.substring(with: (hex.characters.index(hex.startIndex, offsetBy: 1) ..< hex.endIndex))
    }
    
    //get each color
    let r = hex.substring(with: (hex.startIndex ..< hex.characters.index(hex.startIndex, offsetBy: 2)))
    let g = hex.substring(with: (hex.characters.index(hex.startIndex, offsetBy: 2) ..< hex.characters.index(hex.startIndex, offsetBy: 4)))
    let b = hex.substring(with: (hex.characters.index(hex.startIndex, offsetBy: 4) ..< hex.characters.index(hex.startIndex, offsetBy: 6)))
    
    //convert to decimal
    let rd = UInt8(strtoul(r, nil, 16))
    let gd = UInt8(strtoul(g, nil, 16))
    let bd = UInt8(strtoul(b, nil, 16))
    
    //convert to floats from UInt8
    let rdFloat = CGFloat(rd)
    let gdFloat = CGFloat(gd)
    let bdFloat = CGFloat(bd)
    
    return UIColor(red: rdFloat/255, green: gdFloat/255, blue: bdFloat/255, alpha: CGFloat(alpha))
}

/**
    This can be used to make a standard HTTP request.
    This method also sends and receives/stores the "connect.sid"
    cookie which is used to identify unique user sessions.
 */
func httpRequest(_ url: String, type: String, data: [String: String], cb: @escaping (_ responseText: String) -> Void ){
    
    let requestUrl = URL(string: url)
    let request = NSMutableURLRequest(url: requestUrl!)
    request.httpMethod = type
    var postData = ""
    for(key, value) in data{
        postData += key + "=" + value + "&"
    }
    postData = String(postData.characters.dropLast())
    
    request.httpBody = postData.data(using: String.Encoding.utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    if let sid = storage.string(forKey: "connect.sid"){
        request.addValue("connect.sid=\(sid)", forHTTPHeaderField: "Cookie")
    }
    
    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
        data, response, error in
        
        if error != nil {
            print(error ?? "error")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {

            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response!.url!)
            HTTPCookieStorage.shared.setCookies(cookies, for: response!.url!, mainDocumentURL: nil)
            for cookie in cookies {
                var cookieProperties = [HTTPCookiePropertyKey: AnyObject]()
                cookieProperties[HTTPCookiePropertyKey.name] = cookie.name as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.value] = cookie.value as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.domain] = cookie.domain as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.path] = cookie.path as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.version] = NSNumber(value: cookie.version as Int) as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.expires] = Date().addingTimeInterval(31536000) as AnyObject?
                
                let newCookie = HTTPCookie(properties: cookieProperties)
                HTTPCookieStorage.shared.setCookie(newCookie!)
                
                storage.set(cookie.value, forKey: cookie.name)
            }
        }
        
        let responseText = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        
        cb(responseText! as String);
    }) 
    
    task.resume()
}

/**
    This can be used to make a standard HTTP request.
    This method also sends and receives/stores the "connect.sid"
    cookie which is used to identify unique user sessions.
 */
func httpRequest(_ url: String, type: String, cb: @escaping (_ responseText: String) -> Void ){
    
    let requestUrl = URL(string: url)
    let request = NSMutableURLRequest(url: requestUrl!)
    request.httpMethod = type
    
    if let sid = storage.string(forKey: "connect.sid"){
        request.addValue("connect.sid=\(sid)", forHTTPHeaderField: "Cookie")
    }
    
    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
        data, response, error in
        
        if error != nil {
            print(error ?? "error")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response!.url!)
            HTTPCookieStorage.shared.setCookies(cookies, for: response!.url!, mainDocumentURL: nil)
            for cookie in cookies {
                var cookieProperties = [HTTPCookiePropertyKey: AnyObject]()
                cookieProperties[HTTPCookiePropertyKey.name] = cookie.name as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.value] = cookie.value as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.domain] = cookie.domain as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.path] = cookie.path as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.version] = NSNumber(value: cookie.version as Int) as AnyObject?
                cookieProperties[HTTPCookiePropertyKey.expires] = Date().addingTimeInterval(31536000) as AnyObject?
                
                let newCookie = HTTPCookie(properties: cookieProperties)
                HTTPCookieStorage.shared.setCookie(newCookie!)
                
                storage.set(cookie.value, forKey: cookie.name)
            }
        }
        
        let responseText = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        
        cb(responseText! as String);
    }) 
    
    task.resume()
}

/**
    Converts string into a JSON object.
 */
func parseJSON(_ string: String) -> JSON {
    let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
    return JSON(data: data!)
}

func alert(title: String, message: String, buttonText: String, viewController: UIViewController) {
    DispatchQueue.main.async(execute: {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    })
}

func getCurrentYear() -> String {
    //get date at this moment in time
    let date = Date()
    let calendar = Calendar.current
    //split date to day, month and year
    let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
    //store year in storage
    return String(describing: components.year)
}

/**
    Converts a Date object into a readable time.
 */
func timeFromNSDate(_ date: Date) -> String? {
    let calendar = Calendar.current
    let components = (calendar as NSCalendar).components([.hour, .minute], from: date)
    var minutes = String(describing: components.minute!)
    let hours = String((components.hour! - 1) % 12 + 1)
    let suffix: String
    if components.hour! > 11 {
        suffix = "PM"
    } else {
        suffix = "AM"
    }
    //(components.hour! - 1) % 12 + 1
    if minutes.characters.count == 1 {
        minutes = "0" + minutes
    }
    return "\(hours):\(minutes) \(suffix)"
}

/**
    Calculates height for a text view with specified text and width.
 */
func heightForView(_ text:String, width:CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.text = text
    
    label.sizeToFit()
    return label.frame.height
}

/**
    Checks internet connection and if client is connected,
    this method syncs all locally saved reports that were
    not previously sent to the server.
 */
func checkConnectionAndSync() {
    if Reachability.isConnectedToNetwork() {
        if let savedReports = storage.array(forKey: "savedReports") {
            for report in savedReports {
                let data = report as! [String: String]
                sendSubmissionSilently(data)
            }
        }
    }
}

/**
    Submits a report to the server with no activity in the UI.
 */
func sendSubmissionSilently(_ data: [String: String]) {
    httpRequest(baseURL + "/submitReport", type: "POST", data: data) { responseText in
        if responseText != "fail" {
            if let savedReports = storage.array(forKey: "savedReports"){
                if let i = savedReports.index(where: {$0 as! [String : String] == data}) {
                    var newSavedReports = savedReports
                    newSavedReports.remove(at: i)
                    storage.set(newSavedReports, forKey: "savedReports")
                }
            }
        }
    }
}

/**
    Escapes text to be suitable for URLs.
 */
func escape(_ text: String) -> String {
    var newText: String
    newText = text.replacingOccurrences(of: "\"", with: "\\\"")
    newText = newText.replacingOccurrences(of: "+", with: "%2B")
    return newText
}

/**
    Logs out with no activity in the UI.
 */
func logoutSilently() {
    httpRequest(morTeamURL + "/logout", type: "POST"){ responseText in
        for key in storage.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}

/**
    Gets the key for the current regional and stores it locally.
 */
func getCurrentRegionalKey() {
    httpRequest(baseURL + "/getCurrentRegionalInfo", type: "POST"){
        responseText in
        
        let regionalInfo = parseJSON(responseText)
        if !regionalInfo["Errors"].exists() {
            let currentRegionalKey = String(describing: regionalInfo["key"])
            storage.setValue(currentRegionalKey, forKey: "currentRegional")
        }
    }
}

extension String {
    
    var length: Int {
        return self.characters.count
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return self[Range(start ..< end)]
    }
    
}

extension UIViewController {

    /**
        allow user to click on button (or swipe) to open side menu
     */
    func setupMenu(_ button: UIBarButtonItem) {
        if self.revealViewController() != nil {
            button.target = self.revealViewController()
            button.action = #selector((SWRevealViewController.revealToggle) as (SWRevealViewController) -> (Void) -> Void)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    /**
        transition to any view controller using storyboard ID
     */
    func goTo(viewController identifier: String) {
        DispatchQueue.main.async(execute: {
            let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: identifier)
            self.show(vc as! UIViewController, sender: vc)
        })
    }
}
