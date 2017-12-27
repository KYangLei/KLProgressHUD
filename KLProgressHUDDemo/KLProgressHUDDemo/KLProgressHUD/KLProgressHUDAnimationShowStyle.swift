//
//  KLProgressHUDAnimationShowStyle.swift
//  KLProgressHUDDemo
//
//  Created by 雷珂阳 on 2017/12/27.
//  Copyright © 2017年 雷珂阳. All rights reserved.
//

import UIKit

// MARK: - 加载动画样式
public enum KLProgressHUDAnimationShowStyle {
    /// 淡入/淡出（默认）
    case fade
    /// 缩放
    case zoom
    /// 飞入
    case flyInto
}
typealias KLAnimationShowStyle = KLProgressHUDAnimationShowStyle

