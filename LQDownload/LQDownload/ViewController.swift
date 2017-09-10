//
//  ViewController.swift
//  LQDownload
//
//  Created by 杨卢青 on 2017/1/6.
//  Copyright © 2017年 杨卢青. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  // 进度条
  fileprivate lazy var progressView: UIProgressView = {
    let screen = UIScreen.main.bounds
    let rect = CGRect(x: 0, y: screen.height/2, width: screen.width, height: 2)
    let progressView = UIProgressView(frame: rect)
    
    progressView.trackTintColor = UIColor.gray
    progressView.progressTintColor = UIColor.cyan
    return progressView
  }()
  
  // 下载按钮 
  fileprivate lazy var downloadButton: UIButton = {
    let button = UIButton()
    button.setTitle("开始下载", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.layer.borderColor = UIColor.black.cgColor
    button.layer.borderWidth = 2
    button.layer.cornerRadius = 16
    button.frame.size = CGSize(width: 80, height: 40)
    let screen = UIScreen.main.bounds
    button.center = CGPoint(x: screen.width/2, y: screen.height/2 - 80)
    button.addTarget(self, action: #selector(downloadButtonAction), for: .touchUpInside)
    return button
  }()
  
  // 删除按钮
  fileprivate lazy var cancelButton: UIButton = {
    let button = UIButton()
    button.setTitle("取消下载", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.layer.borderColor = UIColor.black.cgColor
    button.layer.borderWidth = 2
    button.layer.cornerRadius = 16
    button.frame.size = CGSize(width: 80, height: 40)
    let screen = UIScreen.main.bounds
    button.center = CGPoint(x: screen.width/2, y: screen.height/2 + 80)
    button.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
    return button
  }()
  
  
  
  let urlString = "https://itunesconnect.apple.com/apploader/ApplicationLoader_3.0.dmg"
  
	override func viewDidLoad() {
		super.viewDidLoad()
    
    if let totalSize = LQDownloadManager.shared.fileTotalSize(urlString) {
      let downloadedSize = LQDownloadManager.shared.fileDownloadSize(urlString)
      
      progressView.progress = Float(downloadedSize)/Float(totalSize)
    }
    
    
    view.addSubview(progressView)
    view.addSubview(downloadButton)
    view.addSubview(cancelButton)
    
		debugPrint("\(LQDownloadManager.shared.downloadDirectory())")
	}

}

extension ViewController {
  func cancelButtonAction() {
    LQDownloadManager.shared.cancelDownload(urlString)
    downloadButton.setTitle("开始下载", for: .normal)
    progressView.setProgress(0, animated: true)
  }
  
  func downloadButtonAction() {
    LQDownloadManager.shared.download("https://itunesconnect.apple.com/apploader/ApplicationLoader_3.0.dmg", progress: { progress in
      print("progress: \(progress)")
      self.progressView.progress = Float(progress)
    }) { status in
      switch status {
      case .start:
        print("开始下载")
        self.downloadButton.setTitle("暂停下载", for: .normal)
      case .suspend:
        print("下载暂停")
        self.downloadButton.setTitle("开始下载", for: .normal)
      case .complete:
        print("下载完成")
        self.downloadButton.setTitle("下载完成", for: .normal)
      case .failed:
        print("下载失败")
        self.downloadButton.setTitle("重新下载", for: .normal)
      }
    }
  }
}

