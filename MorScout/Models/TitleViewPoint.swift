//
//  TitleViewPoint.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/4/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation

class TitleViewPoint: ViewPoint {
    var name: String
    var reportNumber: Int
    var section: ViewPointSectionType
    init(json: JSON, reportNumber: Int, section: ViewPointSectionType){
        self.name = String(json["name"])
        self.reportNumber = reportNumber
        self.section = section
    }
}