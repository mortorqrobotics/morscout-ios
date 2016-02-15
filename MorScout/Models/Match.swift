//
//  Match.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/20/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class Match {
    
    let number: Int
    let time: NSDate?
    let scouted: UInt8
    var redTeams = [String]()
    var blueTeams = [String]()
    
    init(number: Int, time: NSDate?, scouted: UInt8, redTeams: [String], blueTeams: [String]){
        self.number = number
        self.time = time
        self.scouted = scouted
        self.redTeams = redTeams
        self.blueTeams = blueTeams
    }
}