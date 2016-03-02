//
//  Dropdown.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/1/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class Dropdown: DataPoint {
    let name: String
    var options: [String]
    init(json: JSON) {
        name = String(json["name"])
        options = []
        for (_, subJson):(String, JSON) in json["options"] {
            options.append(String(subJson))
        }
    }

    init(name: String, options: [String]){
        self.name = name
        self.options = options
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("name") as! String
        let options = aDecoder.decodeObjectForKey("options") as! [String]
        self.init(name: name, options: options)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(options, forKey: "options")
    }
}