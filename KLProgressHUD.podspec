Pod::Spec.new do |s|
  s.name = 'KLProgressHUD'
  s.version = '1.0.1'
  s.ios.deployment_target = '10.0'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'swift 编写带有进度条显示的HUD。'
  s.homepage = 'https://github.com/KYangLei/KLProgressHUD.git'
  s.authors = { 'KYangLei' => '18683331614@163.com' }
  s.source = { :git => 'https://github.com/KYangLei/KLProgressHUD.git', :tag => s.version }
  s.description = 'KLProgressHUD 是一个在 iOS App 上极易于使用的 HUD。主要用于显示加载、进度、情景信息、Toast。'
  s.source_files = 'KLProgressHUD/*.swift'
  s.resources = 'KLProgressHUD/KLProgressHUD.bundle'
  s.requires_arc = true
  s.frameworks = "Foundation","UIKit"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
end