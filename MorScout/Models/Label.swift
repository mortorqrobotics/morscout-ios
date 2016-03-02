//
//  Label.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/1/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class Label: DataPoint, NSCoding {
    
    let name: String
    
    init(json: JSON) {
        name = String(json["name"])
    }
    
    init(name: String){
        self.name = name
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("name") as! String
        self.init(name: name)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
    }
}