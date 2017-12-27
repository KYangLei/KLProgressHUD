//
//  String-Extension.swift
//  KLProgressHUDDemo
//
//  Created by 雷珂阳 on 2017/12/27.
//  Copyright © 2017年 雷珂阳. All rights reserved.
//

import UIKit

// MARK: - String，获取字符串尺寸
extension String {
    func size(font: UIFont, size: CGSize) -> CGSize {
        let attribute = [ NSAttributedStringKey.font: font ]
        let conten = NSString(string: self)
        return conten.boundingRect(with: CGSize(width: size.width, height: size.height), options: .usesLineFragmentOrigin, attributes: attribute, context: nil).size
    }
}
