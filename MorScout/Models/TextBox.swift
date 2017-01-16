//
//  TextBox.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/1/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import SwiftyJSON

class TextBox: DataPoint {
    
    let name: String
    
    init(json: JSON) {
        name = json["name"].stringValue
    }
    
    init(name: String){
        self.name = name
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        self.init(name: name)
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
    }
}
