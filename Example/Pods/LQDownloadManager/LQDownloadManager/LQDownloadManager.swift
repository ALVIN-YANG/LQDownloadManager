//
//  LQDownloadManager.swift
//  LQDownload
//
//  Created by luqing yang on 2017/9/8.
//  Copyright © 2017年 杨卢青. All rights reserved.
//

import UIKit



open class LQDownloadManager: NSObject {
  
  // 下载状态
  public enum LQDownloadState {
    case start
    case suspend
    case complete
    case failed
  }
  
  struct LQDownloadModel {
    var url: String
    var downloadTask: URLSessionDownloadTask
    var progressBlock: (CGFloat) -> Void
    var completeBlock: (LQDownloadState) -> Void
    var fileExpectedSize: Int?
  }
  
  public static let shared = LQDownloadManager()
  
  public var directoryComponent = "/Documents/Download"
  public var totalLengthComponent = "/Documents/Download/totalLength.plist"
  
  var session = URLSession()
  
  var onGoingDownloads = [String: LQDownloadModel]()
  
  public override init() {
    super.init()
    let configuration = URLSessionConfiguration.default
    self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
  }
}

/// session delegate
extension LQDownloadManager: URLSessionDownloadDelegate, URLSessionDataDelegate {
  
  /// 下载完成 或 失败
  public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    
    guard let urlString = downloadTask.originalRequest?.url?.absoluteString else {
      return
    }
    guard let downloadModel = onGoingDownloads[urlString] else {
      return
    }
    guard let response = downloadTask.response as? HTTPURLResponse else {
      return
    }
    
    if response.statusCode >= 400 {
      OperationQueue.main.addOperation {
        print("status Code: \(response.statusCode)")
        downloadModel.completeBlock(.failed)
      }
      return
    }
    
    onGoingDownloads.removeValue(forKey: urlString)
    
    do {
      try FileManager.default.moveItem(at: location, to: URL.init(fileURLWithPath: fileFullPath(urlString)))
    } catch {
      OperationQueue.main.addOperation {
        downloadModel.completeBlock(.failed)
      }
      return
    }
    
    OperationQueue.main.addOperation {
      downloadModel.completeBlock(.complete)
    }
  }
  
  /// 下载失败
  public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    guard let urlString = task.originalRequest?.url?.absoluteString else {
      return
    }
    guard let downloadModel = onGoingDownloads[urlString] else {
      return
    }
    
    OperationQueue.main.addOperation {
      downloadModel.completeBlock(.failed)
    }
    onGoingDownloads.removeValue(forKey: urlString)
  }
  
  /// 更新下载进度
  public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    
    guard let urlString = downloadTask.originalRequest?.url?.absoluteString else {
      return
    }
    guard var downloadModel = onGoingDownloads[urlString] else {
      return
    }
    
    //存储总长度
    if downloadModel.fileExpectedSize == nil {
      
      downloadModel.fileExpectedSize = Int(totalBytesExpectedToWrite)
      
      var dict = NSMutableDictionary(contentsOf: URL(fileURLWithPath: totalLengthFullPath()))
      if dict == nil {
        dict = NSMutableDictionary()
      }
      dict?[fileName(urlString)] = Int(totalBytesExpectedToWrite)
      dict?.write(toFile: totalLengthFullPath(), atomically: true)
    }
    
    OperationQueue.main.addOperation {
      let progress = CGFloat(totalBytesWritten)/CGFloat(totalBytesExpectedToWrite)
      downloadModel.progressBlock(progress)
    }
    
  }
  
  
  
}

/// Public func
extension LQDownloadManager {
  
  // 开始下载, 或者暂停下载
  public func download(
    _ urlString: String,
    progress: @escaping (_ progress: CGFloat) -> Void,
    completeBlock: @escaping (LQDownloadState) -> Void
    ) {
    
    if isComplate(urlString) {
      completeBlock(.complete)
      debugPrint("(￣.￣)该资源已下载完成")
      return
    }
    
    //任务已存在 执行 继续或暂停
    if let task = self.onGoingDownloads[urlString]?.downloadTask {
      handle(urlString, task)
      return
    }
    
    guard let url = URL(string: urlString) else {
      return
    }
    
    let downloadTask = session.downloadTask(with: url)
    let downloadModel = LQDownloadModel(url: urlString, downloadTask: downloadTask, progressBlock: progress, completeBlock: completeBlock, fileExpectedSize: nil)
    
    downloadModel.completeBlock(.start)
    onGoingDownloads[urlString] = downloadModel
    downloadTask.resume()
  }
  
  /// 取消下载
  public func cancelDownload(_ urlString: String) {
    let state = isInDownloadQueue(urlString)
    if state.0 {
      guard let downloadModel = state.1 else {
        return
      }
      downloadModel.downloadTask.cancel()
      onGoingDownloads.removeValue(forKey: urlString)
    }
    // 删除可能存在的文件
    try? FileManager.default.removeItem(atPath: fileFullPath(urlString))
  }
  
  //判断该资源是否下载完成
  public func isComplate(_ url: String) -> Bool {
    guard let size = fileTotalSize(url) else { return false }
    if size == fileDownloadSize(url) {
      return true
    }
    return false
  }
}

/// Utils
extension LQDownloadManager {
  
  //文件名
  func fileName(_ url: String) -> String {
    
    guard let file = url.removingPercentEncoding?.components(separatedBy: "/").last else {
      return "文件名"
    }
    return file
  }
  
  //文件全路径
  func fileFullPath(_ url: String) -> String {
    return downloadDirectory() + "/\(fileName(url))"
  }
  
  //下载路径: 重新下载或者重新生成的数据放在/Documents/TTDownload里面
  public func downloadDirectory() -> String {
    let path = NSHomeDirectory() + directoryComponent
    if !FileManager.default.fileExists(atPath: path) {
      try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }
    
    return path
  }
  
  //获取对应资源的大小: 大小存储在totalLength.plist, key为url
  public func fileTotalSize(_ url: String) -> Int? {
    if let data = try? Data(contentsOf: URL(fileURLWithPath: totalLengthFullPath())){
      if let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
        return result?[fileName(url)] as? Int
      }
    }
    return nil
  }
  
  //存储文件总长度.plist的文件路径
  func totalLengthFullPath() -> String{
    
    let path = NSHomeDirectory() + totalLengthComponent
    if !FileManager.default.fileExists(atPath: path) {
      FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
    }
    
    return path
  }
  
  //文件已下载大小
  func fileDownloadSize(_ url: String) -> Int {
    var filesize: Int?
    
    do {
      let attr = try FileManager.default.attributesOfItem(atPath: fileFullPath(url))
      filesize = attr[FileAttributeKey.size] as? Int
    } catch {
      return 0
    }
    guard let size = filesize else {
      return 0
    }
    return size
  }
  
  
  //开始或暂停 任务
  func handle(_ urlString: String, _ task: URLSessionDownloadTask) {
    
    switch task.state {
    case .running:
      task.suspend()
      onGoingDownloads[urlString]?.completeBlock(.suspend)
    case .canceling,
         .suspended:
      task.resume()
      onGoingDownloads[urlString]?.completeBlock(.start)
    case .completed:
      break
    }
  }
  
  /// 是否在下载队列中
  func isInDownloadQueue(_ urlString: String) -> (Bool, LQDownloadModel?) {
    for (uniqueKey, downloadModel) in onGoingDownloads {
      if urlString == uniqueKey {
        return (true, downloadModel)
      }
    }
    return (false, nil)
  }
}
