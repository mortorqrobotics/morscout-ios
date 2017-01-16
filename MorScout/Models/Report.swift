//
//  Report.swift
//  MorScout
//
//  Created by Farbod Rafezy on 3/5/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import SwiftyJSON

class Report {
    var data: [[String: String]]
    init(json: JSON) {
        data = []
        for(_, subJson):(String, JSON) in json["data"] {
            data.append([subJson["name"].stringValue: subJson["value"].stringValue])
        }
    }
}
