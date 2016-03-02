//
//  NumberBox.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/1/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class NumberBox: DataPoint {
    let name: String
    let start: Int
    let min: Int
    let max: Int
    
    init(json: JSON) {
        name = String(json["name"])
        start = Int(String(json["start"]))!
        min = Int(String(json["min"]))!
        max = Int(String(json["max"]))!
    }
    
    init(name: String, start: Int, min: Int, max: Int){
        self.name = name
        self.start = start
        self.min = min
        self.max = max
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("name") as! String
        let start = aDecoder.decodeIntegerForKey("start")
        let min = aDecoder.decodeIntegerForKey("min")
        let max = aDecoder.decodeIntegerForKey("max")
        self.init(name: name, start: start, min: min, max: max)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeInteger(start, forKey: "start")
        aCoder.encodeInteger(min, forKey: "min")
        aCoder.encodeInteger(max, forKey: "max")
    }}