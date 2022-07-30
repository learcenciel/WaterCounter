//
//  ViewController.swift
//  WaterCounter
//
//  Created by Александр Борисов on 16.07.2022.
//

import PinLayout
import UIKit

enum WaterCounterScreenState {
    case initial
    case inProgress
}

class WaterCounterViewController: UIViewController {
    
    let waterTrackingController = WaterTrackingController(model: WaterTrackingModel(liquidCount: 1))
    
    var contentView: WaterCounterView {
        view as! WaterCounterView
    }
    
    var screenState: WaterCounterScreenState = .initial
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        waterTrackingController.updateWaterCompletion = { [weak self] waterCount in
            guard let `self` = self else { return }

            self.contentView.updateWaterView(with: waterCount)
        }
    }
    
    override func loadView() {
        view = WaterCounterView()
        contentView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.layout(state: screenState)
        contentView.configureLayout()
    }
}

extension WaterCounterViewController: WaterCountUpdateDelegate {
    
    func waterCountDidUpdate(_ count: Double) {
        waterTrackingController.updateWaterCount(count)
    }
}

extension WaterCounterViewController: WaterCountScreenStateProvidable {}
