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
        let number = aDecoder.decodeInteger(forKey: "number")
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let rank = aDecoder.decodeObject(forKey: "rank") as? Int
        self.init(number: number, name: name, rank: rank)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(number, forKey: "number")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(rank, forKey: "rank")
    }
}
