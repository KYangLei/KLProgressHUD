//
//  KLProgressHUD.swift
//  KLProgressHUDDemo
//
//  Created by 雷珂阳 on 2017/12/27.
//  Copyright © 2017年 雷珂阳. All rights reserved.
//

import UIKit

public typealias KLCompletion = (() -> Void)

public class KLProgressHUD: UIView {
    /// 全局中间变量
    fileprivate var hudType: KLHUDType!
    fileprivate var status: String?
    fileprivate var image: UIImage?
    fileprivate var gifUrl: URL?
    fileprivate var gifSize: CGFloat?
    fileprivate var progress: CGFloat?
    fileprivate var isShow: Bool = false
    fileprivate var completion: KLCompletion?
    
    fileprivate lazy var infoImage: UIImage? = KLConfig.bundleImage(.info)?.withRenderingMode(.alwaysTemplate)
    fileprivate lazy var successImage: UIImage? = KLConfig.bundleImage(.success)?.withRenderingMode(.alwaysTemplate)
    fileprivate lazy var errorImage: UIImage? = KLConfig.bundleImage(.error)?.withRenderingMode(.alwaysTemplate)
    
    // MARK: - UI
    fileprivate lazy var screenView: UIView = {
        $0.frame = CGRect(x: 0, y: 0, width: self.screenWidht, height: self.screenHeight)
        $0.mask?.alpha = 0.3
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        $0.alpha = 0.3
        $0.backgroundColor = KLConfig.maskBackgroundColor
        return $0
    }(UIView())
    
    fileprivate lazy var contentView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        view.layer.cornerRadius = KLConfig.cornerRadius
        if KLConfig.effectStyle == .none {
            view.backgroundColor = KLConfig.backgroundColor
        } else {
            view.backgroundColor = .clear
        }
        view.alpha = 0
        return view
    }()
    
    fileprivate lazy var contentBlurView: UIVisualEffectView = {
        var blurEffectStyle: UIBlurEffectStyle!
        switch KLConfig.effectStyle {
        case .extraLight:
            blurEffectStyle = .extraLight
        case .light:
            blurEffectStyle = .light
        default:
            blurEffectStyle = .dark
        }
        let blurEffect = UIBlurEffect(style: blurEffectStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        blurEffectView.alpha = KLConfig.effectAlpha
        
        return blurEffectView
    }()
    
    /// gif(KLProgressHUDType)
    fileprivate lazy var gifView: KLProgressHUDGifView = KLProgressHUDGifView()
    
    /// image(KLProgressHUDType)
    fileprivate lazy var imageView: UIImageView = {
        $0.contentMode = .scaleToFill
        $0.tintColor = KLConfig.foregroundColor
        return $0
    }(UIImageView())
    
    /// progress(KLProgressHUDType)
    fileprivate lazy var progressView: KLProgressView = {
        $0.progressColor = KLConfig.foregroundColor
        $0.backgroundColor = .clear
        return $0
    }(KLProgressView(frame: CGRect(x: 0, y: 0, width: 85, height: 85)))
    
    /// activityIndicator(KLProgressHUDType)
    fileprivate var activityIndicatorView: UIView {
        get {
            return KLConfig.animationStyle == KLAnimationStyle.circle ? self.circleHUDView : self.systemHUDView
        }
    }
    
    fileprivate lazy var systemHUDView: UIActivityIndicatorView = {
        $0.activityIndicatorViewStyle = .whiteLarge
        $0.color = KLConfig.foregroundColor
        $0.sizeToFit()
        $0.startAnimating()
        return $0
    }(UIActivityIndicatorView())
    
    fileprivate lazy var circleHUDView: UIView = {
        let lineWidth: CGFloat = 3
        let lineMargin: CGFloat = lineWidth / 2
        let arcCenter = CGPoint(x: $0.width / 2 - lineMargin, y: $0.height / 2 - lineMargin)
        let smoothedPath = UIBezierPath(arcCenter: arcCenter, radius: $0.width / 2 - lineWidth, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        let layer = CAShapeLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.frame = CGRect(x: lineMargin, y: lineMargin, width: arcCenter.x * 2, height: arcCenter.y * 2)
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = KLConfig.foregroundColor.cgColor
        layer.lineWidth = 3
        layer.lineCap = kCALineCapRound
        layer.lineJoin = kCALineJoinBevel
        layer.path = smoothedPath.cgPath
        
        layer.mask = CALayer()
        layer.mask?.contents = KLConfig.bundleImage(.mask)?.cgImage
        layer.mask?.frame = layer.bounds
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = (Double.pi * 2)
        animation.duration = 1
        animation.isRemovedOnCompletion = false
        animation.repeatCount = Float(Int.max)
        animation.autoreverses = false
        layer.add(animation, forKey: "rotate")
        
        $0.layer.addSublayer(layer)
        return $0
    }(UIView(frame: CGRect(x: 0, y: 0, width: 65, height: 65)))
    
    fileprivate lazy var statusLabel: UILabel = {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = KLConfig.foregroundColor
        return $0
    }(UILabel())
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(KLProgressHUD.observerDismiss), name: KLConfig.KLNSNotificationDismiss, object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: KLConfig.KLNSNotificationDismiss, object: nil)
    }
}

// MARK: - 实例计算属性
extension KLProgressHUD {
    fileprivate var screenWidht: CGFloat {
        get {
            return UIScreen.main.bounds.size.width
        }
    }
    
    fileprivate var screenHeight: CGFloat {
        get {
            return UIScreen.main.bounds.size.height
        }
    }
    
    fileprivate var maxContentViewWidth: CGFloat {
        get {
            return self.screenWidht - KLConfig.margin * 2
        }
    }
    
    fileprivate var maxContentViewChildWidth: CGFloat {
        get {
            return self.screenWidht - KLConfig.margin * 4
        }
    }
}

extension KLProgressHUD {
    /// 显示
    fileprivate func show(hudType: KLHUDType,
                          status: String? = nil,
                          image: UIImage? = nil,
                          isAutoDismiss: Bool? = nil,
                          maskStyle: KLMaskStyle? = nil,
                          imageType: KLImageType? = nil,
                          gifUrl: URL? = nil,
                          gifSize: CGFloat? = nil,
                          progress: CGFloat? = nil,
                          completion: KLCompletion? = nil,
                          onlyOnceFont: UIFont? = nil) {
        DispatchQueue.main.async {
            self.hudType = hudType
            self.status = status == "" ? nil : status
            self.image = image
            self.gifUrl = gifUrl
            self.gifSize = gifSize
            self.progress = progress ?? 0
            self.completion = completion
            if let imgType = imageType {
                switch imgType {
                case .info:
                    self.image = self.infoImage
                case .error:
                    self.image = self.errorImage
                case .success:
                    self.image = self.successImage
                default: break
                }
            }
            if self.hudType == .progress {
                if let progressValue = self.progress {
                    self.progressView.progress = Double(progressValue)
                }
                if self.restorationIdentifier != KLConfig.restorationIdentifier {
                    self.updateView(maskStyle: maskStyle)
                }
            } else {
                self.updateView(maskStyle: maskStyle)
            }
            
            self.updateFrame(maskStyle: maskStyle, statusFont: onlyOnceFont ?? KLConfig.font)
            if let autoDismiss = isAutoDismiss {
                if autoDismiss {
                    self.autoDismiss(delay: KLConfig.autoDismissDelay)
                }
            }
        }
    }
    /// 更新视图
    fileprivate func updateView(maskStyle: KLMaskStyle?) {
        self.restorationIdentifier = KLConfig.restorationIdentifier
        KLProgressHUD.frontWindow?.addSubview(self)
        if (maskStyle ?? KLConfig.maskStyle) == .visible {
            self.addSubview(self.screenView)
        }
        self.addSubview(self.contentView)
        if KLConfig.effectStyle != .none {
            self.contentView.addSubview(self.contentBlurView)
        }
        self.contentView.addSubview(self.statusLabel)
        switch self.hudType! {
        case .gif:
            if let url = self.gifUrl {
                self.gifView.frame.size = CGSize(width: self.gifSize ?? 100, height: self.gifSize ?? 100)
                self.gifView.showGIFImage(gifUrl: url)
                self.contentView.addSubview(self.gifView)
            }
            break
        case .image:
            self.contentView.addSubview(self.imageView)
            break
        case .progress:
            self.contentView.addSubview(self.progressView)
            break
        case .activityIndicator:
            self.contentView.addSubview(self.activityIndicatorView)
        default: break
        }
    }
    /// 更新视图大小坐标
    fileprivate func updateFrame(maskStyle: KLMaskStyle?, statusFont: UIFont) {
        if self.hudType! == .gif {
            if self.gifView.width > self.maxContentViewChildWidth {
                self.gifView.frame.size = CGSize(width: self.maxContentViewChildWidth, height: self.maxContentViewChildWidth)
            }
        }
        if self.hudType! == .image {
            self.imageView.image = self.image
            self.imageView.sizeToFit()
            // 如果图片尺寸超过限定最大尺寸，将图片尺寸修改为限定最大尺寸
            if self.imageView.width > self.maxContentViewChildWidth {
                self.imageView.frame.size = CGSize(width: self.maxContentViewChildWidth, height: self.maxContentViewChildWidth)
            }
        }
        
        if let text = self.status {
            self.statusLabel.isHidden = false
            self.statusLabel.text = text
            self.statusLabel.font = statusFont
            self.statusLabel.frame.size = text.size(font: statusFont, size: CGSize(width: self.maxContentViewChildWidth, height: 400))
        } else {
            self.statusLabel.frame.size = CGSize.zero
            self.statusLabel.isHidden = true
        }
        
        self.contentView.frame.size = {
            var width: CGFloat = 0
            switch self.hudType! {
            case .gif:
                width = (self.statusLabel.isHidden ? self.gifView.width : (self.gifView.width > self.statusLabel.width ? self.gifView.width : self.statusLabel.width)) + KLConfig.margin * 2
            case .image:
                width = (self.statusLabel.isHidden ? self.imageView.width : (self.imageView.width > self.statusLabel.width ? self.imageView.width : self.statusLabel.width)) + KLConfig.margin * 2
            case .message:
                width = self.statusLabel.width + KLConfig.margin * 2
            case .progress:
                width = (self.statusLabel.isHidden ? self.progressView.width : (self.progressView.width > self.statusLabel.width ? self.progressView.width : self.statusLabel.width)) + KLConfig.margin * 2
            case .activityIndicator:
                width = (self.statusLabel.isHidden ? self.activityIndicatorView.width : (self.activityIndicatorView.width > self.statusLabel.width ? self.activityIndicatorView.width : self.statusLabel.width)) + KLConfig.margin * 2
            }
            
            var height: CGFloat = 0
            switch self.hudType! {
            case .gif:
                height = (self.statusLabel.isHidden ? self.gifView.height : (self.gifView.height + KLConfig.margin + self.statusLabel.height)) + KLConfig.margin * 2
            case .image:
                height = (self.statusLabel.isHidden ? self.imageView.height : (self.imageView.height + KLConfig.margin + self.statusLabel.height)) + KLConfig.margin * 2
            case .message:
                height = self.statusLabel.height + KLConfig.margin * 2
            case .progress:
                height = (self.statusLabel.isHidden ? self.progressView.height : (self.progressView.height + KLConfig.margin + self.statusLabel.height)) + KLConfig.margin * 2
            case .activityIndicator:
                height = (self.statusLabel.isHidden ? self.activityIndicatorView.height : (self.activityIndicatorView.height + KLConfig.margin + self.statusLabel.height)) + KLConfig.margin * 2
            }
            
            return CGSize(width: width, height: height)
        }()
        
        self.contentBlurView.frame = CGRect(x: 0, y: 0, width: self.contentView.width, height: self.contentView.height)
        switch self.hudType! {
        case .gif:
            self.gifView.frame.origin = {
                let x = (self.contentView.width - self.gifView.width) / 2
                let y = KLConfig.margin
                return CGPoint(x: x, y: y)
            }()
            self.statusLabel.frame.origin = {
                let x = (self.contentView.width - self.statusLabel.width) / 2
                let y = self.gifView.y + self.gifView.height + KLConfig.margin
                return CGPoint(x: x, y: y)
            }()
        case .image:
            self.imageView.frame.origin = {
                let x = (self.contentView.width - self.imageView.width) / 2
                let y = KLConfig.margin
                return CGPoint(x: x, y: y)
            }()
            self.statusLabel.frame.origin = {
                let x = (self.contentView.width - self.statusLabel.width) / 2
                let y = self.imageView.y + self.imageView.height + KLConfig.margin
                return CGPoint(x: x, y: y)
            }()
        case .message:
            self.statusLabel.frame.origin = {
                let x = (self.contentView.width - self.statusLabel.width) / 2
                let y = KLConfig.margin
                return CGPoint(x: x, y: y)
            }()
        case .progress:
            self.progressView.frame.origin = {
                let x = (self.contentView.width - self.progressView.width) / 2
                let y = KLConfig.margin
                return CGPoint(x: x, y: y)
            }()
            self.statusLabel.frame.origin = {
                let x = (self.contentView.width - self.statusLabel.width) / 2
                let y = self.progressView.y + self.progressView.height + KLConfig.margin
                return CGPoint(x: x, y: y)
            }()
        case .activityIndicator:
            self.activityIndicatorView.frame.origin = {
                let x = (self.contentView.width - self.activityIndicatorView.width) / 2
                let y = KLConfig.margin
                return CGPoint(x: x, y: y)
            }()
            self.statusLabel.frame.origin = {
                let x = (self.contentView.width - self.statusLabel.width) / 2
                let y = self.activityIndicatorView.y + self.activityIndicatorView.height + KLConfig.margin
                return CGPoint(x: x, y: y)
            }()
        }
        
        let x = (self.screenWidht - self.contentView.width) / 2
        let y = (self.screenHeight - self.contentView.height) / 2
        if (maskStyle ?? KLConfig.maskStyle) == .hide {
            self.frame = CGRect(x: x, y: y, width: self.contentView.width, height: self.contentView.height)
            self.contentView.frame.origin = CGPoint(x: 0, y: 0)
        } else {
            self.frame = CGRect(x: 0, y: 0, width: self.screenWidht, height: self.screenHeight)
            self.contentView.frame.origin = CGPoint(x: x, y: y)
        }
        
        if !self.isShow {
            self.animationShow(contentFrame: self.contentView.frame)
        }
    }
    /// 动画显示
    func animationShow(contentFrame: CGRect) {
        self.isShow = true
        switch KLConfig.animationShowStyle {
        case .fade:
            self.contentView.alpha = 0
        case .zoom:
            self.contentView.alpha = 1
            self.contentView.frame = CGRect(x: self.screenWidht / 2, y: contentFrame.origin.y, width: 0, height: contentFrame.size.height)
        case .flyInto:
            self.contentView.alpha = 1
            self.contentView.frame = CGRect(x: contentFrame.origin.x, y: 0 - contentFrame.size.height, width: contentFrame.size.width, height: contentFrame.size.height)
            break
        }
        UIView.animate(withDuration: 0.3, animations: {
            switch KLConfig.animationShowStyle {
            case .fade:
                self.contentView.alpha = 1
            case .zoom:
                self.contentView.frame = contentFrame
            case .flyInto:
                self.contentView.frame = contentFrame
                break
            }
        })
    }
    /// 动画移除
    func animationDsmiss() {
        UIView.animate(withDuration: 0.3, animations: {
            switch KLConfig.animationShowStyle {
            case .fade:
                self.contentView.alpha = 0
            case .zoom:
                self.contentView.frame = CGRect(x: self.screenWidht / 2, y: self.contentView.y, width: 0, height: self.contentView.height)
            case .flyInto:
                self.contentView.frame = CGRect(x: self.contentView.x, y: 0 - self.contentView.height, width: self.contentView.width, height: self.contentView.height)
                break
            }
        }, completion: { (finished) in
            self.isShow = false
            self.removeFromSuperview()
            self.completion?()
        })
    }
    /// 通知移除
    @objc fileprivate func observerDismiss(notification: Notification) {
        if let userInfo = notification.userInfo {
            let delay = userInfo["delay"] as! Double
            self.autoDismiss(delay: delay)
        } else {
            self.isShow = false
            self.removeFromSuperview()
        }
    }
    /// 自动移除
    fileprivate func autoDismiss(delay: Double) {
        let a = Int(delay * 1000 * 1000)
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .microseconds(a), execute: {
            DispatchQueue.main.async {
                self.animationDsmiss()
            }
        })
    }
}

// MARK: - 类计算属性
extension KLProgressHUD {
    fileprivate static var frontWindow: UIWindow? {
        get {
            let window = UIApplication.shared.windows.reversed().first(where: {
                $0.screen == UIScreen.main &&
                    !$0.isHidden && $0.alpha > 0 &&
                    $0.windowLevel == UIWindowLevelNormal
            })
            return window
        }
    }
    
    static var shared: KLProgressHUD {
        get {
            return KLProgressHUD(frame: UIScreen.main.bounds)
        }
    }
}

// MARK: - 类方法
extension KLProgressHUD {
    //MARK: 显示gif加载
    public static func showGif(gifUrl: URL?, gifSize: CGFloat?) {
        KLProgressHUD.showGif(status: nil, gifUrl: gifUrl, gifSize: gifSize, onlyOnceFont: nil)
    }
    public static func showGif(status: String?, gifUrl: URL?, gifSize: CGFloat?, onlyOnceFont: UIFont? = nil) {
        KLProgressHUD.showGif(status: status, gifUrl: gifUrl, gifSize: gifSize, maskStyle: nil, onlyOnceFont: onlyOnceFont)
    }
    public static func showGif(status: String?, gifUrl: URL?, gifSize: CGFloat?, maskStyle: KLProgressHUDMaskStyle?, onlyOnceFont: UIFont? = nil) {
        shared.show(hudType: .gif, status: status, maskStyle: maskStyle, gifUrl: gifUrl, gifSize: gifSize, onlyOnceFont: onlyOnceFont)
    }
    
    //MARK: 显示图片
    public static func showImage(_ image: UIImage?, completion: KLCompletion? = nil) {
        KLProgressHUD.showImage(image: image, status: nil, completion: completion)
    }
    public static func showImage(image: UIImage?, status: String?, completion: KLCompletion? = nil) {
        KLProgressHUD.showImage(image: image, status: status, onlyOnceFont: nil, completion: completion)
    }
    public static func showImage(image: UIImage?, status: String?, onlyOnceFont: UIFont?, completion: KLCompletion? = nil) {
        KLProgressHUD.showImage(image: image, status: status, maskStyle: nil, onlyOnceFont: onlyOnceFont, completion: completion)
    }
    public static func showImage(image: UIImage?, status: String?, maskStyle: KLProgressHUDMaskStyle?, completion: KLCompletion? = nil) {
        KLProgressHUD.showImage(image: image, status: status, maskStyle: maskStyle, onlyOnceFont: nil, completion: completion)
    }
    public static func showImage(image: UIImage?, status: String?, maskStyle: KLProgressHUDMaskStyle?, onlyOnceFont: UIFont?, completion: KLCompletion? = nil) {
        shared.show(hudType: .image, status: status, image: image, isAutoDismiss: true, maskStyle: maskStyle, completion: completion, onlyOnceFont: onlyOnceFont)
    }
    
    //MARK: 显示消息
    public static func showMessage(_ message: String?, completion: KLCompletion? = nil) {
        KLProgressHUD.showMessage(message, onlyOnceFont: nil, completion: completion)
    }
    public static func showMessage(_ message: String?, onlyOnceFont: UIFont?, completion: KLCompletion? = nil) {
        KLProgressHUD.showMessage(message: message, maskStyle: nil, onlyOnceFont: onlyOnceFont, completion: completion)
    }
    public static func showMessage(message: String?, maskStyle: KLProgressHUDMaskStyle?, completion: KLCompletion? = nil) {
        KLProgressHUD.showMessage(message: message, maskStyle: maskStyle, onlyOnceFont: nil, completion: completion)
    }
    public static func showMessage(message: String?, maskStyle: KLProgressHUDMaskStyle?, onlyOnceFont: UIFont?, completion: KLCompletion? = nil) {
        shared.show(hudType: .message, status: message, isAutoDismiss: true, maskStyle: maskStyle, completion: completion, onlyOnceFont: onlyOnceFont)
    }
    
    //MARK: 显示进度
    public static func showProgress(_ progress: CGFloat?) {
        KLProgressHUD.showProgress(progress, status: nil)
    }
    public static func showProgress(_ progress: CGFloat?, status: String?, onlyOnceFont: UIFont? = nil) {
        KLProgressHUD.showProgress(progress: progress, status: status, maskStyle: nil, onlyOnceFont: onlyOnceFont)
    }
    public static func showProgress(progress: CGFloat?, status: String?, maskStyle: KLProgressHUDMaskStyle?, onlyOnceFont: UIFont? = nil) {
        var isShowProgressView = false
        for subview in (KLProgressHUD.frontWindow?.subviews)! {
            if subview.isKind(of: KLProgressHUD.self) && subview.restorationIdentifier == KLConfig.restorationIdentifier {
                let progressHUD = subview as! KLProgressHUD
                if progressHUD.hudType == .progress {
                    progressHUD.show(hudType: .progress, status: status, maskStyle: maskStyle, progress: progress, onlyOnceFont: onlyOnceFont)
                    isShowProgressView = true
                } else {
                    progressHUD.removeFromSuperview()
                }
            }
        }
        if !isShowProgressView {
            shared.show(hudType: .progress, status: status, maskStyle: maskStyle, progress: progress, onlyOnceFont: onlyOnceFont)
        }
    }
    
    //MARK: 显示加载
    public static func show() {
        KLProgressHUD.show(nil)
    }
    public static func show(_ status: String?, onlyOnceFont: UIFont? = nil) {
        KLProgressHUD.show(status: status, maskStyle: nil, onlyOnceFont: onlyOnceFont)
    }
    public static func show(status: String?, maskStyle: KLProgressHUDMaskStyle?, onlyOnceFont: UIFont? = nil) {
        shared.show(hudType: .activityIndicator, status: status, maskStyle: maskStyle, onlyOnceFont: onlyOnceFont)
    }
    
    //MARK: 显示普通信息
    public static func showInfo(_ status: String?, completion: KLCompletion? = nil) {
        KLProgressHUD.showInfo(status, onlyOnceFont: nil, completion: completion)
    }
    public static func showInfo(_ status: String?, onlyOnceFont: UIFont?, completion: KLCompletion? = nil) {
        KLProgressHUD.showInfo(status: status, maskStyle: nil, onlyOnceFont: onlyOnceFont, completion: completion)
    }
    public static func showInfo(status: String?, maskStyle: KLProgressHUDMaskStyle?, completion: KLCompletion? = nil) {
        KLProgressHUD.showInfo(status: status, maskStyle: maskStyle, onlyOnceFont: nil, completion: completion)
    }
    public static func showInfo(status: String?, maskStyle: KLProgressHUDMaskStyle?, onlyOnceFont: UIFont?, completion: KLCompletion? = nil) {
        shared.show(hudType: .image, status: status, isAutoDismiss: true, maskStyle: maskStyle, imageType: .info, completion: completion, onlyOnceFont: onlyOnceFont)
    }
    
    //MARK: 显示成功信息
    public static func showSuccess(_ status: String?, completion: KLCompletion? = nil) {
        KLProgressHUD.showSuccess(status, onlyOnceFont: nil, completion: completion)
    }
    public static func showSuccess(_ status: String?, onlyOnceFont: UIFont?, completion: KLCompletion? = nil) {
        KLProgressHUD.showSuccess(status: status, maskStyle: nil, onlyOnceFont: onlyOnceFont, completion: completion)
    }
    public static func showSuccess(status: String?, maskStyle: KLProgressHUDMaskStyle?, completion: KLCompletion? = nil) {
        KLProgressHUD.showSuccess(status: status, maskStyle: maskStyle, onlyOnceFont: nil, completion: completion)
    }
    public static func showSuccess(status: String?, maskStyle: KLProgressHUDMaskStyle?, onlyOnceFont: UIFont?, completion: KLCompletion? = nil) {
        shared.show(hudType: .image, status: status, isAutoDismiss: true, maskStyle: maskStyle, imageType: .success, completion: completion, onlyOnceFont: onlyOnceFont)
    }
    
    //MARK: 显示失败信息
    public static func showError(_ status: String?, completion: KLCompletion? = nil) {
        KLProgressHUD.showError(status, onlyOnceFont: nil, completion: completion)
    }
    public static func showError(_ status: String?, onlyOnceFont: UIFont?, completion: KLCompletion? = nil) {
        KLProgressHUD.showError(status: status, maskStyle: nil, onlyOnceFont: onlyOnceFont, completion: completion)
    }
    public static func showError(status: String?, maskStyle: KLProgressHUDMaskStyle?, completion: KLCompletion? = nil) {
        KLProgressHUD.showError(status: status, maskStyle: maskStyle, onlyOnceFont: nil, completion: completion)
    }
    public static func showError(status: String?, maskStyle: KLProgressHUDMaskStyle?, onlyOnceFont: UIFont?, completion: KLCompletion? = nil) {
        shared.show(hudType: .image, status: status, isAutoDismiss: true, maskStyle: maskStyle, imageType: .error, completion: completion, onlyOnceFont: onlyOnceFont)
    }
    
    @available(swift, deprecated: 3.0, message: "请使用 dismiss 方法")
    public static func hide(delay: Double? = nil) {
        KLProgressHUD.dismiss(delay)
    }
    //MARK: 移除
    public static func dismiss(_ delay: Double? = nil) {
        NotificationCenter.default.post(name: KLConfig.KLNSNotificationDismiss, object: nil, userInfo: ["delay" : delay ?? 0])
    }
    
    //MARK: 设置遮罩样式，默认值：.visible
    public static func setMaskStyle (_ maskStyle: KLProgressHUDMaskStyle) {
        KLConfig.maskStyle = maskStyle
    }
    
    //MARK: 设置动画显示/隐藏样式，默认值：.fade
    public static func setAnimationShowStyle (_ animationShowStyle: KLProgressHUDAnimationShowStyle) {
        KLConfig.animationShowStyle = animationShowStyle
    }
    
    //MARK: 设置遮罩背景色，默认值：.black
    public static func setMaskBackgroundColor(_ color: UIColor) {
        KLConfig.effectStyle = .none
        KLConfig.maskBackgroundColor = color
    }
    
    //MARK: 设置前景色，默认值：.white（前景色在设置 effectStyle 值时会自动适配，如果要使用自定义前景色，在调用 setEffectStyle 方法后调用 setForegroundColor 方法即可）
    public static func setForegroundColor(_ color: UIColor) {
        KLConfig.foregroundColor = color
    }
    //MARK: 设置 HUD 毛玻璃效果（与 backgroundColor 互斥，如果设置毛玻璃效果不是.none，则根据样式自动设置前景色），默认值：.dark
    public static func setEffectStyle(_ hudEffectStyle: KLProgressHUDEffectStyle) {
        KLConfig.effectStyle = hudEffectStyle
        if hudEffectStyle == .light || hudEffectStyle == .extraLight {
            KLConfig.foregroundColor = .black
        } else if hudEffectStyle == .dark {
            KLConfig.foregroundColor = .white
        }
    }
    //MARK: 设置 HUD 毛玻璃透明度，默认值：1
    public static func setEffectAlpha(_ effectAlpha: CGFloat) {
        KLConfig.effectAlpha = effectAlpha
    }
    //MARK: 设置 HUD 背景色（与 effectStyle 互斥，如果设置背景色，effectStyle = .none），默认值：UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.8)
    public static func setBackgroundColor(_ color: UIColor) {
        KLConfig.backgroundColor = color
        KLConfig.effectStyle = .none
    }
    
    //MARK: 设置字体，默认值：UIFont.boldSystemFont(ofSize: 15)
    public static func setFont(_ font: UIFont) {
        KLConfig.font = font
    }
    
    //MARK: 设置圆角，默认值：6
    public static func setCornerRadius(_ cornerRadius: CGFloat) {
        KLConfig.cornerRadius = cornerRadius
    }
    
    //MARK: 设置加载动画样式动画样式，默认值：circle
    public static func setAnimationStyle(_ animationStyle: KLProgressHUDAnimationStyle) {
        KLConfig.animationStyle  = animationStyle
    }
    
    //MARK: 设置自动隐藏延时秒数，默认值：2
    public static func setAutoDismissDelay(_ autoDismissDelay: Double) {
        KLConfig.autoDismissDelay = autoDismissDelay
    }
}
