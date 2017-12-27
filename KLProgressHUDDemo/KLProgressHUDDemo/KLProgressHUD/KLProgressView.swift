//
//  KLProgressView.swift
//  KLProgressHUDDemo
//
//  Created by 雷珂阳 on 2017/12/27.
//  Copyright © 2017年 雷珂阳. All rights reserved.
//

import UIKit

class KLProgressView: UIView {
    var progressColor: UIColor?
    var progressFont: UIFont?
    private var _progress: Double = 0
    private var textLabel: UILabel!
    var progress: Double {
        get {
            return _progress
        }
        set {
            self._progress = newValue
            self.setNeedsDisplay()
            self.setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textLabel = UILabel()
        self.addSubview(self.textLabel)
        self.textLabel.textAlignment = .center
        self.textLabel.font = self.progressFont ?? KLConfig.font
        self.textLabel.textColor = self.progressColor ?? KLConfig.foregroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel.text = "\(Int(self.progress * 100))%"
        self.textLabel.sizeToFit()
        self.textLabel.frame.origin = CGPoint(x: (self.width - self.textLabel.width) / 2, y: (self.height - self.textLabel.height) / 2)
    }
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        let arcCenter = CGPoint(x: self.width / 2, y: self.width / 2)
        let radius = arcCenter.x - 2
        let startAngle = -(Double.pi / 2)
        let endAngle = startAngle + Double.pi * 2 * self.progress
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true)
        ctx!.setLineWidth(4)
        self.progressColor?.setStroke()
        ctx!.addPath(path.cgPath)
        ctx!.strokePath()
    }

}
