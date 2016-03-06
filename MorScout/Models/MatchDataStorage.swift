//
//  MatchDataStorage.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/5/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class MatchDataStorage {
    
    static let sharedInstance = MatchDataStorage()
    
    var data = [String: [String: [String: [String: [Report]]]]]()
    
}