//
//  Match.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/20/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class Match: NSObject, NSCoding {
    
    let number: Int
    let time: Date?
    var redTeams = [String]()
    var blueTeams = [String]()
    
    init(number: Int, time: Date?, redTeams: [String], blueTeams: [String]){
        self.number = number
        self.time = time
        self.redTeams = redTeams
        self.blueTeams = blueTeams
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let number = aDecoder.decodeInteger(forKey: "number")
        let time = aDecoder.decodeObject(forKey: "time") as? Date
        let redTeams = aDecoder.decodeObject(forKey: "redTeams") as! [String]
        let blueTeams = aDecoder.decodeObject(forKey: "blueTeams") as! [String]
        self.init(number: number, time: time, redTeams: redTeams, blueTeams: blueTeams)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(number, forKey: "number")
        aCoder.encode(time, forKey: "time")
        aCoder.encode(redTeams, forKey: "redTeams")
        aCoder.encode(blueTeams, forKey: "blueTeams")
    }
}
