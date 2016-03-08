//
//  Team.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/20/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class Team: NSObject, NSCoding {
    let number: Int
    let name: String
    let rank: Int?
    
    init(number: Int, name: String, rank: Int?) {
        self.number = number
        self.name = name
        self.rank = rank
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let number = aDecoder.decodeIntegerForKey("number")
        let name = aDecoder.decodeObjectForKey("name") as! String
        let rank = aDecoder.decodeObjectForKey("rank") as? Int
        self.init(number: number, name: name, rank: rank)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(number, forKey: "number")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(rank, forKey: "rank")
    }
}