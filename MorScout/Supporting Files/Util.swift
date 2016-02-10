//
//  Util.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/8/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit

let storage = NSUserDefaults.standardUserDefaults()
let baseURL = "http://127.0.0.1:8080"

func UIColorFromHex(var hex: String) -> UIColor {
    
    
    if hex.hasPrefix("#") {
        hex = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(1), end: hex.endIndex))
    }
    
    //get each color
    let r = hex.substringWithRange(Range<String.Index>(start: hex.startIndex, end: hex.startIndex.advancedBy(2)))
    let g = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(2), end: hex.startIndex.advancedBy(4)))
    let b = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(4), end: hex.startIndex.advancedBy(6)))
    
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

func UIColorFromHex(var hex: String, alpha: Double) -> UIColor {
    if hex.hasPrefix("#") {
        hex = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(1), end: hex.endIndex))
    }
    
    //get each color
    let r = hex.substringWithRange(Range<String.Index>(start: hex.startIndex, end: hex.startIndex.advancedBy(2)))
    let g = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(2), end: hex.startIndex.advancedBy(4)))
    let b = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(4), end: hex.startIndex.advancedBy(6)))
    
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

func httpRequest(url: String, type: String, data: [String: String], cb: (responseText: String) -> Void ){
    
    let requestUrl = NSURL(string: url)
    let request = NSMutableURLRequest(URL: requestUrl!)
    request.HTTPMethod = type
    var postData = ""
    for(key, value) in data{
        postData += key + "=" + value + "&"
    }
    postData = String(postData.characters.dropLast())
    
    request.HTTPBody = postData.dataUsingEncoding(NSUTF8StringEncoding)
    
    if let sid = storage.stringForKey("connect.sid"){
        request.addValue("connect.sid=\(sid)", forHTTPHeaderField: "Cookie")
    }
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
        data, response, error in
        
        if error != nil {
            print(error)
            return
        }
        
        if let httpResponse = response as? NSHTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
            let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(fields, forURL: response!.URL!)
            NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response!.URL!, mainDocumentURL: nil)
            for cookie in cookies {
                var cookieProperties = [String: AnyObject]()
                cookieProperties[NSHTTPCookieName] = cookie.name
                cookieProperties[NSHTTPCookieValue] = cookie.value
                cookieProperties[NSHTTPCookieDomain] = cookie.domain
                cookieProperties[NSHTTPCookiePath] = cookie.path
                cookieProperties[NSHTTPCookieVersion] = NSNumber(integer: cookie.version)
                cookieProperties[NSHTTPCookieExpires] = NSDate().dateByAddingTimeInterval(31536000)
                
                let newCookie = NSHTTPCookie(properties: cookieProperties)
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(newCookie!)
                
                storage.setObject(cookie.value, forKey: cookie.name)
            }
        }
        
        let responseText = NSString(data: data!, encoding: NSUTF8StringEncoding)
        
        cb(responseText: responseText! as String);
    }
    
    task.resume()
}

func httpRequest(url: String, type: String, cb: (responseText: String) -> Void ){
    
    let requestUrl = NSURL(string: url)
    let request = NSMutableURLRequest(URL: requestUrl!)
    request.HTTPMethod = type
    
    if let sid = storage.stringForKey("connect.sid"){
        request.addValue("connect.sid=\(sid)", forHTTPHeaderField: "Cookie")
    }
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
        data, response, error in
        
        if error != nil {
            print(error)
            return
        }
        
        if let httpResponse = response as? NSHTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
            let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(fields, forURL: response!.URL!)
            NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response!.URL!, mainDocumentURL: nil)
            for cookie in cookies {
                var cookieProperties = [String: AnyObject]()
                cookieProperties[NSHTTPCookieName] = cookie.name
                cookieProperties[NSHTTPCookieValue] = cookie.value
                cookieProperties[NSHTTPCookieDomain] = cookie.domain
                cookieProperties[NSHTTPCookiePath] = cookie.path
                cookieProperties[NSHTTPCookieVersion] = NSNumber(integer: cookie.version)
                cookieProperties[NSHTTPCookieExpires] = NSDate().dateByAddingTimeInterval(31536000)
                
                let newCookie = NSHTTPCookie(properties: cookieProperties)
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(newCookie!)
                
                storage.setObject(cookie.value, forKey: cookie.name)
            }
        }
        
        let responseText = NSString(data: data!, encoding: NSUTF8StringEncoding)
        
        cb(responseText: responseText! as String);
    }
    
    task.resume()
}
func parseJSON(string: String) -> JSON {
    let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    return JSON(data: data!)
}

func alert(title title: String, message: String, buttonText: String, viewController: UIViewController) {
    dispatch_async(dispatch_get_main_queue(),{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.Default, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    })
}

func getCurrentYear() -> String {
    //get date at this moment in time
    let date = NSDate()
    let calendar = NSCalendar.currentCalendar()
    //split date to day, month and year
    let components = calendar.components([.Day , .Month , .Year], fromDate: date)
    //store year in storage
    return String(components.year)
}

func timeFromNSDate(date: NSDate) -> String {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Hour, .Minute], fromDate: date)
    return String(components.hour) + ":" + String(components.minute)
}
