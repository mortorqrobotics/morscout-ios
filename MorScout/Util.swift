//
//  Util.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/8/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import Foundation
import UIKit

func UIColorFromHex(var hex: String) -> UIColor {
    
    
    if hex.hasPrefix("#") {
        hex = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(1), end: hex.endIndex))
    }
    
    //get each color
    let r = hex.substringWithRange(Range<String.Index>(start: hex.startIndex, end: hex.startIndex.advancedBy(2)))
    let g = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(2), end: hex.startIndex.advancedBy(4)))
    let b = hex.substringWithRange(Range<String.Index>(start: hex.startIndex.advancedBy(4), end: hex.startIndex.advancedBy(6)))
    
    //convert to decimal
    let rd = UInt8(strtoul(r, nil, 16))
    let gd = UInt8(strtoul(g, nil, 16))
    let bd = UInt8(strtoul(b, nil, 16))
    
    //convert to floats from UInt8
    let rdFloat = CGFloat(rd)
    let gdFloat = CGFloat(gd)
    let bdFloat = CGFloat(bd)
    
    return UIColor(red: rdFloat/255, green: gdFloat/255, blue: bdFloat/255, alpha: 1)
}
