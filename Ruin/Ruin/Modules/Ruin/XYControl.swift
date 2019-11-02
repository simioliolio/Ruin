//
//  XYControl.swift
//  Ruin
//
//  Created by Simon Haycock on 02/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import UIKit

@IBDesignable final class XYControl: UIControl {
    
    private let minimumOfXAndY: CGFloat = 0
    private let maximumOfXAndY: CGFloat = 1
    private var rangeOfXAndY: CGFloat {
        maximumOfXAndY - minimumOfXAndY
    }
    
    private let dot = CALayer()
    private let dotBackground = UIColor.white
    private let dotBorderWidth: CGFloat = 2
    private let dotDiameterAsFractionOfWidth: CGFloat = 0.1
    private var dotDiameter: CGFloat {
        dotDiameterAsFractionOfWidth * frame.width
    }
    private var dotSize: CGSize {
        CGSize(width: dotDiameter, height: dotDiameter)
    }
    private var positionOfDotAsPercentage: CGPoint = CGPoint(x: 0.5, y: 0.5)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        layer.cornerRadius = 5
        
        dot.backgroundColor = dotBackground.cgColor
        layer.addSublayer(dot)
        
        updateDotFrame()
    }
    
    func updateDotFrame() {
        dot.frame = CGRect(origin: positionOfDotAsPercentage.scaledTo(bounds.size),
                           size: dotSize)
    }
}

extension CGPoint {
    
    func scaledTo(_ size: CGSize) -> CGPoint {
        guard x <= 1.0, y <= 1.0 else {
            fatalError("Point \(self) is unsuitable for scaling")
        }
        return CGPoint(x: x * size.width, y: y * size.height)
    }
}
