//
//  DataViewPoint.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/4/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class DataViewPoint: ViewPoint {
    var name: String
    var value: String
    var reportNumber: Int
    var section: ViewPointSectionType
    init(json: JSON, reportNumber: Int, section: ViewPointSectionType){
        self.name = String(json["name"])
        self.value = String(json["value"])
        self.reportNumber = reportNumber
        self.section = section
    }
}