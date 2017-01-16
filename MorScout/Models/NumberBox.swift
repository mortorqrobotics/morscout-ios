//
//  NumberBox.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/1/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import SwiftyJSON

class NumberBox: DataPoint {
    let name: String
    let start: Int
    let min: Int
    let max: Int
    
    init(json: JSON) {
        name = json["name"].stringValue
        start = json["start"].intValue
        min = json["min"].intValue
        max = json["max"].intValue
    }
    
    init(name: String, start: Int, min: Int, max: Int){
        self.name = name
        self.start = start
        self.min = min
        self.max = max
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let start = aDecoder.decodeInteger(forKey: "start")
        let min = aDecoder.decodeInteger(forKey: "min")
        let max = aDecoder.decodeInteger(forKey: "max")
        self.init(name: name, start: start, min: min, max: max)
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(start, forKey: "start")
        aCoder.encode(min, forKey: "min")
        aCoder.encode(max, forKey: "max")
    }}
