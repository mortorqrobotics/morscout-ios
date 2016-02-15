//
//  Team.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/20/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class Team {
    let number: Int
    let name: String
    let rank: Int?
    
    init(number: Int, name: String, rank: Int?){
        self.number = number
        self.name = name
        self.rank = rank
    }
}