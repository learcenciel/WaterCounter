//
//  WaterTrackingController.swift
//  WaterCounter
//
//  Created by Александр Борисов on 30.07.2022.
//

import Foundation

class WaterTrackingController {
    
    var waterTrackingModel: WaterTrackingModel
    var updateWaterCompletion: ((Double) -> Void)?
    
    init(model: WaterTrackingModel) {
        waterTrackingModel = model
    }
    
    func updateWaterCount(_ count: Double) {
        if abs(1.0 - waterTrackingModel.liquidCount) > 1.0 {
            waterTrackingModel.setLiquidCount(0)
        } else if 1.0 - waterTrackingModel.liquidCount < 0 {
            waterTrackingModel.setLiquidCount(1)
        }
        
        waterTrackingModel.setLiquidCount(count)
        updateWaterCompletion?(waterTrackingModel.liquidCount)
    }
}
