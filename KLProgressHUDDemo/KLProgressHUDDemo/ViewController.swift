//
//  ViewController.swift
//  KLProgressHUDDemo
//
//  Created by 雷珂阳 on 2017/12/27.
//  Copyright © 2017年 雷珂阳. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var progressValue: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.title = "KLProgressHUD"
        
        /**加载动画样式*/
        KLProgressHUD.setAnimationStyle(.circle)
        /**遮罩样式*/
        KLProgressHUD.setMaskStyle(.visible)
        /**加载动画样式*/
        KLProgressHUD.setAnimationShowStyle(.fade)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
  
            if indexPath.row > 9 {
                KLProgressHUD.setEffectStyle(.dark)
            } else {
                KLProgressHUD.setEffectStyle(.dark)
            }
            if indexPath.row == 0 {
                KLProgressHUD.show()
                KLProgressHUD.dismiss(2.5)
            } else if indexPath.row == 1 {
                KLProgressHUD.show("正在拼命的加载中")
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(2), execute: {
                    DispatchQueue.main.async {
                        KLProgressHUD.dismiss()
                        KLProgressHUD.showInfo("加载完成")
                    }
                })
            } else if indexPath.row == 2 {
                Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.showProgressTimerHandler(timer:)), userInfo: nil, repeats: true)
            } else if indexPath.row == 3 {
                Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.showProgressTimerHandler(timer:)), userInfo: "上传中...", repeats: true)
            } else if indexPath.row == 4 {
                KLProgressHUD.showImage(UIImage(named: "typeImage.JPG"))
            } else if indexPath.row == 5 {
                KLProgressHUD.showImage(image: UIImage(named: "typeImage.JPG"), status: "图片会自动消失")
            } else if indexPath.row == 6 {
                KLProgressHUD.showInfo("Star 一下吧")
            } else if indexPath.row == 7 {
                KLProgressHUD.showSuccess("操作成功")
            } else if indexPath.row == 8 {
                KLProgressHUD.showError("出现错误了")
            } else if indexPath.row == 9 {
                KLProgressHUD.showMessage("开始使用 KLProgressHUD 吧")
            } else if indexPath.row == 10 {
                KLProgressHUD.showGif(gifUrl: Bundle.main.url(forResource: "loader", withExtension: "gif"), gifSize: 80)
                KLProgressHUD.dismiss(2)
            } else if indexPath.row == 11 {
                KLProgressHUD.showGif(status: "加载GIF图", gifUrl: Bundle.main.url(forResource: "loader", withExtension: "gif"), gifSize: 80)
                KLProgressHUD.dismiss(2)
            }
            else {
                KLProgressHUD.showMessage("操作成功")
                /**自定义字体*/
//                KLProgressHUD.showMessage("临时使用一次字体", onlyOnceFont: UIFont.boldSystemFont(ofSize: 20))
        }
    }
    
    @objc func showProgressTimerHandler(timer: Timer) {
        if self.progressValue >= 100 {
            if timer.isValid {
                timer.invalidate()
            }
            KLProgressHUD.dismiss()
            KLProgressHUD.showSuccess("加载完成")
            self.progressValue = 0
        } else {
            self.progressValue += 5
            if let status = timer.userInfo {
                KLProgressHUD.showProgress(self.progressValue / 100, status: status as? String)
            } else {
                KLProgressHUD.showProgress(self.progressValue / 100)
            }
            
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

