//
//  XYControl.swift
//  Ruin
//
//  Created by Simon Haycock on 02/11/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

import UIKit

@IBDesignable final class XYControl: UIControl {
    
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
    }
}
