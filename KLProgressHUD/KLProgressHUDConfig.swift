//
//  KLProgressHUDConfig.swift
//  KLProgressHUDDemo
//
//  Created by 雷珂阳 on 2017/12/27.
//  Copyright © 2017年 雷珂阳. All rights reserved.
//

import UIKit

// MARK: - KLProgressHUD 全局配置
final class KLProgressHUDConfig {
    static let margin: CGFloat = 20
    static var maskStyle: KLMaskStyle = .visible
    static var animationShowStyle: KLAnimationShowStyle = .fade
    static var maskBackgroundColor: UIColor = .black
    static var foregroundColor: UIColor = .white
    static var effectStyle: KLHUDEffectStyle = .dark
    static var effectAlpha: CGFloat = 1
    static var backgroundColor: UIColor = UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.8)
    static var font: UIFont = UIFont.boldSystemFont(ofSize: 15)
    static var cornerRadius: CGFloat = 6
    static var animationStyle: KLAnimationStyle = .circle
    static var autoDismissDelay: Double = 2
    
    static let restorationIdentifier: String = "KLProgressHUD"
    static let KLNSNotificationDismiss = NSNotification.Name(rawValue: "KLNSNotificationDismiss")
    
    private static let imageBundle = Bundle(url: Bundle(for: KLProgressHUD.self).url(forResource: "KLProgressHUD", withExtension: "bundle")!)
    
    static func bundleImage(_ imageType: KLImageType) -> UIImage? {
        var imageName: String!
        switch imageType {
        case .mask:
            imageName = "angle-mask"
        case .info:
            imageName = "info"
        case .error:
            imageName = "error"
        case .success:
            imageName = "success"
        }
        return UIImage(contentsOfFile: (imageBundle?.path(forResource: imageName, ofType: "png"))!)
    }
}
typealias KLConfig = KLProgressHUDConfig
