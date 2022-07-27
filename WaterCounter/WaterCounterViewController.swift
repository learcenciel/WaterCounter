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
        
    private let waterPercentageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 48)
        label.text = "0%"
        label.textAlignment = .center
        label.textColor = .black
        label.isHidden = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var isCoffeeScaled = false
    var isPureWaterScaled = false
    
    let waterShapeLayer = CAShapeLayer()
    
    var state: WaterCounterScreenState = .initial
    
    private let countDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = "is 0/3000 ML"
        label.isHidden = false
        label.textAlignment = .center
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let addCoffeeButton: UIButton = {
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = UIColor(red: 22/255, green: 31/255, blue: 126/255, alpha: 1)
        buttonConfiguration.image = UIImage(systemName: "cup.and.saucer")
        let button = UIButton(configuration: buttonConfiguration, primaryAction: nil)
        button.alpha = 0
        
        return button
    }()
    
    private let addPureWaterButton: UIButton = {
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = UIColor(red: 22/255, green: 31/255, blue: 126/255, alpha: 1)
        buttonConfiguration.image = UIImage(systemName: "drop")
        
        let button = UIButton(configuration: buttonConfiguration, primaryAction: nil)
        button.alpha = 0
        
        return button
    }()
    private let addPureWaterScalingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 22/255, green: 31/255, blue: 126/255, alpha: 1)
        view.alpha = 0
        
        return view
    }()
    
    private let addLiquidButton: UIButton = {
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .systemBlue
        buttonConfiguration.image = UIImage(systemName: "plus")
        let button = UIButton(configuration: buttonConfiguration)
        button.configurationUpdateHandler = { _button in
            switch _button.state {
            case .highlighted:
                _button.configuration?.background.backgroundColor = nil
            default:
                break
            }
        }
        
        return button
    }()
    private let addCoffeeScalingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 22/255, green: 31/255, blue: 126/255, alpha: 1)
        view.alpha = 0
        
        return view
    }()
    
    let waveView = WaveView()
    
    var waterCount = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(waveView)
        view.addSubview(waterPercentageLabel)
        view.addSubview(countDescriptionLabel)
        view.addSubview(addCoffeeScalingView)
        view.addSubview(addCoffeeButton)
        view.addSubview(addPureWaterScalingView)
        view.addSubview(addPureWaterButton)
        view.addSubview(addLiquidButton)
        
        view.backgroundColor = .white
        
        setupGestures()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layout()
        configureLayout()
    }
    
    private func layout() {
        let buttonSize = CGSize(width: 72, height: 72)
        addCoffeeButton.pin.bottomLeft(20).size(buttonSize)
        addLiquidButton.pin.bottomCenter(32).size(buttonSize)
        addCoffeeScalingView.pin.center(to: addCoffeeButton.anchor.center).size(buttonSize)
        addPureWaterButton.pin.bottomRight(20).size(buttonSize)
        addPureWaterScalingView.pin.center(to: addPureWaterButton.anchor.center).size(buttonSize)
        
        waterPercentageLabel.pin.hCenter().vCenter().sizeToFit()
        countDescriptionLabel.pin.below(of: waterPercentageLabel, aligned: .center).margin(8).sizeToFit()
        waveView.pin.horizontally().bottom(-view.bounds.size.height * waterCount).height(of: view)
    }
    
    private func configureLayout() {
        addCoffeeButton.layer.cornerRadius = addCoffeeButton.frame.height / 2
        addCoffeeButton.layer.masksToBounds = true
        addLiquidButton.layer.cornerRadius = addLiquidButton.frame.height / 2
        addLiquidButton.layer.masksToBounds = true
        addCoffeeScalingView.layer.cornerRadius = addCoffeeScalingView.frame.height / 2
        addCoffeeScalingView.layer.masksToBounds = true
        addPureWaterButton.layer.cornerRadius = addPureWaterButton.frame.height / 2
        addPureWaterButton.layer.masksToBounds = true
        addPureWaterScalingView.layer.cornerRadius = addPureWaterScalingView.frame.height / 2
        addPureWaterScalingView.layer.masksToBounds = true
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(plusButtonDidDragged(_:)))
        addLiquidButton.addGestureRecognizer(panGesture)
    }
    
    var initialPoint: CGPoint = .zero
    @objc private func plusButtonDidDragged(_ r: UIPanGestureRecognizer) {
        let translation = r.translation(in: r.view!)
        
        switch r.state {
        case .began:
            if state == .initial {
                let scaleAnimation = CASpringAnimation(keyPath: "transform.scale")
                scaleAnimation.toValue = 1.25
                scaleAnimation.isRemovedOnCompletion = false
                scaleAnimation.fillMode = .forwards
                scaleAnimation.duration = 0.1
                scaleAnimation.damping = 30
                scaleAnimation.stiffness = 800
                
                addLiquidButton.layer.add(scaleAnimation, forKey: nil)
            }
            
            initialPoint = addLiquidButton.center
            
            showOtherButtonsIfNeeded()
            
            state = .inProgress
        case .changed:
            addLiquidButton.center = CGPoint(
                x: initialPoint.x + translation.x,
                y: initialPoint.y + translation.y)
                
            scaleCoffeeButtonIfIntersects(addCoffeeButton.frame)
            scalePureWaterButtonIfIntersects(addPureWaterButton.frame)
        default:
            break
        }
    }
    
    private func showOtherButtonsIfNeeded() {
        guard state == .initial else { return }
        
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.toValue = 1
        alphaAnimation.isRemovedOnCompletion = false
        alphaAnimation.fillMode = .forwards
        alphaAnimation.duration = 0.1
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.5
        scaleAnimation.toValue = 1
        scaleAnimation.duration = 0.1
        scaleAnimation.isRemovedOnCompletion = false
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [alphaAnimation, scaleAnimation]
        animationGroup.duration = 0.2
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.delegate = self
        
        addCoffeeButton.layer.add(animationGroup, forKey: nil)
        addPureWaterButton.layer.add(animationGroup, forKey: nil)
    }
    
    private func scaleCoffeeButtonIfIntersects(_ coffeeButtonFrame: CGRect) {
        if addLiquidButton.frame.intersects(coffeeButtonFrame) && !isCoffeeScaled {
            isCoffeeScaled = true
            
            let scaleAnimation = CASpringAnimation(keyPath: "transform.scale")
            scaleAnimation.toValue = 4
            scaleAnimation.isRemovedOnCompletion = false
            scaleAnimation.fillMode = .forwards
            scaleAnimation.duration = 1
            scaleAnimation.damping = 30
            scaleAnimation.stiffness = 800
            
            changeWaterCount(value: -0.1)
            animateBetweenPaths()
            
            addCoffeeScalingView.layer.add(scaleAnimation, forKey: nil)
        } else if !addLiquidButton.frame.intersects(coffeeButtonFrame) && isCoffeeScaled {
            isCoffeeScaled = false
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.toValue = 1
            scaleAnimation.isRemovedOnCompletion = false
            scaleAnimation.fillMode = .forwards
            scaleAnimation.duration = 0.15

            addCoffeeScalingView.layer.add(scaleAnimation, forKey: nil)
        }
    }
    
    private func scalePureWaterButtonIfIntersects(_ pureWaterButtonFrame: CGRect) {
        if addLiquidButton.frame.intersects(pureWaterButtonFrame) && !isPureWaterScaled {
            isPureWaterScaled = true
            
            let scaleAnimation = CASpringAnimation(keyPath: "transform.scale")
            scaleAnimation.toValue = 4
            scaleAnimation.isRemovedOnCompletion = false
            scaleAnimation.fillMode = .forwards
            scaleAnimation.duration = 1
            scaleAnimation.damping = 30
            scaleAnimation.stiffness = 800
            
            changeWaterCount(value: 0.1)
            animateBetweenPaths()

            addPureWaterScalingView.layer.add(scaleAnimation, forKey: nil)
        } else if !addLiquidButton.frame.intersects(pureWaterButtonFrame) && isPureWaterScaled  {
            isPureWaterScaled = false
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.toValue = 1
            scaleAnimation.isRemovedOnCompletion = false
            scaleAnimation.fillMode = .forwards
            scaleAnimation.duration = 0.15

            addPureWaterScalingView.layer.add(scaleAnimation, forKey: nil)
        }
    }
}

// MARK: - Private extension
private extension WaterCounterViewController {
    
    func changeWaterCount(value: Double) {
        waterCount += value
    }
    
    func animateBetweenPaths() {
        let value = Int(round(abs(1 - waterCount) * 3000.0))
        countDescriptionLabel.text = "is \(value)/3000 ML"
        waterPercentageLabel.text = "\(Int(round(abs((1.0 - waterCount) * 100))))%"
        countDescriptionLabel.sizeToFit()
        waterPercentageLabel.sizeToFit()
                
        waveView.animationStart(direction: .right, speed: 3)
        UIView.animate(
            withDuration: 3,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0,
            options: [.curveEaseInOut]) {
                self.waveView.pin.horizontally().bottom(-self.view.bounds.size.height * self.waterCount).height(of: self.view)
            }
    }
}

// MARK: - CAAnimationDelegate
extension WaterCounterViewController: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            [addCoffeeScalingView, addPureWaterScalingView].forEach { $0.alpha = 1 }
        }
    }
}
