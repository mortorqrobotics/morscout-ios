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
    let time: NSDate?
    var redTeams = [String]()
    var blueTeams = [String]()
    
    init(number: Int, time: NSDate?, redTeams: [String], blueTeams: [String]){
        self.number = number
        self.time = time
        self.redTeams = redTeams
        self.blueTeams = blueTeams
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let number = aDecoder.decodeIntegerForKey("number")
        let time = aDecoder.decodeObjectForKey("time") as? NSDate
        let redTeams = aDecoder.decodeObjectForKey("redTeams") as! [String]
        let blueTeams = aDecoder.decodeObjectForKey("blueTeams") as! [String]
        self.init(number: number, time: time, redTeams: redTeams, blueTeams: blueTeams)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(number, forKey: "number")
        aCoder.encodeObject(time, forKey: "time")
        aCoder.encodeObject(redTeams, forKey: "redTeams")
        aCoder.encodeObject(blueTeams, forKey: "blueTeams")
    }
}