//
//  WaterTrackingModel.swift
//  WaterCounter
//
//  Created by Александр Борисов on 30.07.2022.
//

import Foundation

struct WaterTrackingModel {
    var liquidCount: Double
    
    mutating func setLiquidCount(_ count: Double) {
        liquidCount += count
    }
}
