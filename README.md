# KLProgressHUD
## 实现功能

- [x] 显示加载和文字信息
- [x] 显示 Gif 加载和文字信息
- [x] 显示进度
- [x] 显示图片和文字信息
- [x] 显示情景信息（info、success、error）
- [x] 显示 Toast 样式信息
- [x] 遮罩自定义显示
- [x] 显示动画
- [x] 自定义（背景色、前景色、字体、自动消失间隔秒、遮罩、动画类型、毛玻璃效果...），满足极大多数场景
- [x] 显示完成回调
- [x] 临时显示字体

## 运行环境

* iOS 10.0 +
* Xcode 8 +
* Swift 3.0 +

## 安装

### CocoaPods

你可以使用 [CocoaPods](http://cocoapods.org/) 安装 `KLProgressHUD`，在你的 `Podfile` 中添加：

```ogdl
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
pod 'KLProgressHUD'
end
```

### 手动安装

* 拖动 `KLProgressHUD` 文件夹到您的项目
* 将 `KLProgressHUD.bundle` 添加到项目资源中 `Targets->Build Phases->Copy Bundle Resources`

## 快速使用

### 导入 `KLProgressHUD`

```swift
import KLProgressHUD
```

### 显示完成回调（新增）

```swift
KLProgressHUD.showMessage("开始使用 KLProgressHUD 吧", completion: {
// 输入代码
})
```

回调支持的函数有：

* showImage
* showMessage
* showInfo
* showSuccess
* showError

### 显示加载

```swift
KLProgressHUD.show()
DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(3), execute: {
DispatchQueue.main.async {
KLProgressHUD.dismiss()
}
})
```

### 显示加载和文字

```swift
KLProgressHUD.show("正在拼命的加载中")
DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(3), execute: {
DispatchQueue.main.async {
KLProgressHUD.dismiss()
KLProgressHUD.showInfo("加载完成")
}
})
```

### 显示 Gif 加载

```swift
KLProgressHUD.showGif(gifUrl: Bundle.main.url(forResource: "loader", withExtension: "gif"), gifSize: 80)
DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(3), execute: {
DispatchQueue.main.async {
KLProgressHUD.dismiss()
}
})
```

### 显示 Gif 和文字加载

```swift
KLProgressHUD.showGif(status: "正在拼命的加载中", gifUrl: Bundle.main.url(forResource: "loader", withExtension: "gif"), gifSize: 80)
DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(3), execute: {
DispatchQueue.main.async {
KLProgressHUD.dismiss()
}
})
```

### 显示进度

```swift
KLProgressHUD.showProgress(1 / 10)
```

### 显示图片

```swift
KLProgressHUD.showImage(UIImage(named: "typeImage"))
```

### 显示图片和文字

```swift
KLProgressHUD.showImage(image: UIImage(named: "typeImage"), status: "图片会自动消失")
```

### 显示情景 -> 信息❗️

```swift
KLProgressHUD.showInfo("Star一下吧")
```

### 显示情景 -> 成功✅

```swift
KLProgressHUD.showSuccess("操作成功")
```

### 显示情景 -> 错误❌

```swift
KLProgressHUD.showError("出现错误了")
```

### 显示 Toast 样式信息

```swift
KLProgressHUD.showMessage("开始使用 KLProgressHUD 吧")
```

### 隐藏

```swift
KLProgressHUD.dismiss()
```

### 延迟隐藏

```swift
KLProgressHUD.dismiss(delay: 3)
```

## 自定义显示样式

### 设置遮罩样式，默认值：.visible

```swift
/// 隐藏
/// hide

/// 显示
/// visible
setMaskStyle (_ maskStyle: KLProgressHUDMaskStyle)
```

### 设置动画显示/隐藏样式，默认值：.fade

```swift
/// 淡入/淡出（默认）
/// fade

/// 缩放
/// zoom

/// 飞入
/// flyInto
setAnimationShowStyle (_ animationShowStyle: KLProgressHUDAnimationShowStyle)
```

### 设置遮罩背景色，默认值：.black

```swift
setMaskBackgroundColor(_ color: UIColor)
```

### 设置前景色，默认值：.white（前景色在设置 effectStyle 值时会自动适配，如果要使用自定义前景色，在调用 setEffectStyle 方法后调用 setForegroundColor 方法即可）

```swift
setForegroundColor(_ color: UIColor)
```

### 设置 HUD 毛玻璃效果（与 backgroundColor 互斥，如果设置毛玻璃效果不是.none，则根据样式自动设置前景色），默认值：.dark

```swift
setEffectStyle(_ hudEffectStyle: KLProgressHUDEffectStyle)
```

### 设置 HUD 毛玻璃透明度，默认值：1

```swift
setEffectAlpha(_ effectAlpha: CGFloat)
```

### 设置 HUD 背景色（与 effectStyle 互斥，如果设置背景色，effectStyle = .none），默认值：UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.8)

```swift
setBackgroundColor(_ color: UIColor)
```

### 设置字体，默认值：UIFont.boldSystemFont(ofSize: 15)

```swift
setFont(_ font: UIFont)
```

### 设置圆角，默认值：6

```swift
setCornerRadius(_ cornerRadius: CGFloat)
```

### 设置加载动画样式动画样式，默认值：circle

```swift
/// 圆圈
/// circle

/// 系统样式（菊花）
/// system
setAnimationStyle(_ animationStyle: KLProgressHUDAnimationStyle)
```

### 设置自动隐藏延时秒数，默认值：2

```swift
setAutoDismissDelay(_ delay: Int)
```

