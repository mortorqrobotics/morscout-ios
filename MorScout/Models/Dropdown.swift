//
//  Dropdown.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/1/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import SwiftyJSON

class Dropdown: DataPoint {
    let name: String
    var options: [String]
    init(json: JSON) {
        name = json["name"].stringValue
        options = []
        for (_, subJson):(String, JSON) in json["options"] {
            options.append(subJson.stringValue)
        }
    }

    init(name: String, options: [String]){
        self.name = name
        self.options = options
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let options = aDecoder.decodeObject(forKey: "options") as! [String]
        self.init(name: name, options: options)
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(options, forKey: "options")
    }
}
