//
//  WaveView.swift
//  WaterCounter
//
//  Created by Александр Борисов on 24.07.2022.
//

import UIKit

class WaveView: UIView {
    
    enum Direction {
        case right
        case left
    }
    
    private weak var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    
    var myLayer = CAShapeLayer()
    
    var speed: Double = 10
    var frequency = 4.0
    var parameterA = 1.5
    var parameterB = 9.0
    var phase = 0.0
    
    var heightOffset = 0.05
    
    var preferredColor = UIColor(red: 116/255, green: 204/255, blue: 244/255, alpha: 0.5)
    var preferredStrokeColor = UIColor(red: 116/255, green: 204/255, blue: 244/255, alpha: 1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        myLayer.frame = rect
        let width = Double(self.frame.width)
        let height = Double(self.frame.height)
        
        let mid = height * heightOffset
        
        let waveLength = width / self.frequency
        let waveHeightCoef = Double(self.frequency)
        path.move(to: CGPoint(x: 0, y: self.frame.maxY))
        path.addLine(to: CGPoint(x: 0, y: mid))
        
        for x in stride(from: 0, through: width, by: 1) {
            let actualX = x / waveLength
            let sine = -cos(self.parameterA*(actualX + self.phase)) * sin((actualX + self.phase)/self.parameterB)
            let y = waveHeightCoef * sine + mid
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: CGFloat(width), y: self.frame.maxY))
        path.addLine(to: CGPoint(x: 0, y: self.frame.maxY))
        
        myLayer.path = path.cgPath
        myLayer.fillColor = preferredColor.cgColor
        myLayer.strokeColor = preferredStrokeColor.cgColor
        myLayer.lineWidth = 3
        self.layer.addSublayer(self.myLayer)
    }
    
    private func startDisplayLink() {
        startTime = CACurrentMediaTime()
        displayLink?.invalidate()
        let displayLink = CADisplayLink(target: self, selector:#selector(handleDisplayLink(_:)))
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
    }
    
    @objc private func handleDisplayLink(_ displayLink: CADisplayLink) {
        phase = (CACurrentMediaTime() - startTime) * self.speed
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        setNeedsDisplay()
    }
    
    func animationStart(direction: Direction, speed: Double) {
        if direction == .right {
            self.speed = -speed
        } else {
            self.speed = speed
        }
        startDisplayLink()
    }
}
