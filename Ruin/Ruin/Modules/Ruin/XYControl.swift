//
//  XYControl.swift
//  Ruin
//
//  Created by Simon Haycock on 02/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import UIKit

protocol XYControlDelegate: class {
    func xyControl(_ xyControl: XYControl, didUpdateTo state: XYControl.Status)
}

final class XYControl: UIControl {
    
    struct Status {
        let activated: Bool
        let point: CGPoint
    }
    
    weak var delegate: XYControlDelegate?
    
    let touchView = UIView()

    private let dot = CALayer()
    private let dotBackground = UIColor.white
    private let dotBorderWidth: CGFloat = 2
    private let dotDiameterAsFractionOfWidth: CGFloat = 0.15
    private var dotDiameter: CGFloat {
        dotDiameterAsFractionOfWidth * frame.width
    }
    private var dotRadius: CGFloat {
        return dotDiameter / 2
    }
    private var dotSize: CGSize {
        CGSize(width: dotDiameter, height: dotDiameter)
    }
    private var positionOfDotAsPercentage: CGPoint = CGPoint(x: 0.5, y: 0.5) {
        didSet {
            delegate?.xyControl(self, didUpdateTo: currentStatus)
            updateDotInView()
        }
    }
    private var activated: Bool = false
    private var currentStatus: XYControl.Status {
        return Status(activated: activated, point: positionOfDotAsPercentage)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        layer.cornerRadius = 5
        
        setupTouchView()
        // TODO: Delete
        touchView.layer.borderWidth = 1.0
        
        dot.backgroundColor = dotBackground.cgColor
        touchView.layer.addSublayer(dot)
        
        updateDotInView()
    }
    
    private func setupTouchView() {
        touchView.translatesAutoresizingMaskIntoConstraints = false
        touchView.isUserInteractionEnabled = false
        self.addSubview(touchView)
        self.pin(view: touchView, with: dotRadius)
    }
    
    override var frame: CGRect {
        didSet {
            updateDotInView()
        }
    }
    
    override func layoutSubviews() {
        updateDotInView()
        super.layoutSubviews()
    }
    
    private func updateDotInView() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        dot.frame.size = dotSize
        dot.cornerRadius = dotRadius
        dot.borderWidth = dotBorderWidth
        let positionInTouchView = positionOfDotAsPercentage.scaledTo(touchView.bounds.size)
        dot.position = positionInTouchView
        dot.setNeedsDisplay()
        CATransaction.commit()
    }
}

extension XYControl {
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        activated = true
        let positionInTouchView = touch.location(in: touchView)
        moveDotTo(positionInTouchView)
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        activated = true
        let positionInTouchView = touch.location(in: touchView)
        moveDotTo(positionInTouchView)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        activated = false
        if let positionInTouchView = touch?.location(in: touchView) {
            moveDotTo(positionInTouchView)
        }
    }
    
    private func moveDotTo(_ positionInTouchView: CGPoint) {
        guard touchView.bounds.contains(positionInTouchView) else { return }
        positionOfDotAsPercentage = positionInTouchView.scaledTo(CGSize.unit, from: touchView.bounds.size)
    }
}

private extension CGPoint {
    
    func scaledTo(_ size: CGSize, from initialSize: CGSize = CGSize.unit) -> CGPoint {
        guard x <= initialSize.width, y <= initialSize.height else {
            fatalError("Point \(self) is beyond bounds of reference size")
        }
        let newX = x / initialSize.width * size.width
        let newY = y / initialSize.height * size.height
        return CGPoint(x: newX, y: newY)
    }
    
    func location(in rect: CGRect) -> CGPoint {
        return CGPoint(x: x - rect.origin.x, y: y - rect.origin.y)
    }
}

private extension CGSize {
    static var unit = CGSize(width: 1, height: 1)
}

private extension UIEdgeInsets {
    static func insetOnAllSides(by inset: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
}

extension UIView {
    
    func pin(view: UIView, with inset: CGFloat) {
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -inset).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: inset).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: -inset).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: inset).isActive = true
    }
}
