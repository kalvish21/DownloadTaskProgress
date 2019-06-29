//
//  ViewController.swift
//  QLPreview
//
//  Created by Kalyan Vishnubhatla on 6/28/19.
//  Copyright © 2019 Kalyan Vishnubhatla. All rights reserved.
//

import UIKit
import QuickLook

class ViewController: UIViewController, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    @IBOutlet weak var progressBar: UIProgressView!
    var previewItem: URL!
    let url = URL(string: "https://www.paypalobjects.com/webstatic/lvm/hk/en/merchant-welcome.pdf")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.setProgress(0, animated: true)
    }
    
    @IBAction func downloadClicked(_ sender: Any) {
        let config = URLSessionConfiguration.background(withIdentifier: "com.example.DownloadTaskExample.background")
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        let task = session.downloadTask(with: url)
        task.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            DispatchQueue.main.async {
                self.progressBar.setProgress(progress, animated: true)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo localURL: URL) {
        let fileManager = FileManager()
        let destinationFilename = url.lastPathComponent
        var destinationURL = localURL
        destinationURL.deleteLastPathComponent()
        destinationURL = destinationURL.appendingPathComponent(destinationFilename)
        if fileManager.fileExists(atPath: destinationURL.path) {
            try! fileManager.removeItem(at: destinationURL);
        }
        try! fileManager.copyItem(at: localURL, to: destinationURL)
        self.previewItem = destinationURL
        
        DispatchQueue.main.async {
            let previewController = QLPreviewController()
            previewController.dataSource = self
            self.present(previewController, animated: true, completion: nil)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    }
}

extension ViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItem as QLPreviewItem
    }
}
