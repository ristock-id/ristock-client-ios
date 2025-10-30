//
//  NetworkServiceDelegate.swift
//  RiSTOCK
//
//  Created by Codex on 2025-03-17.
//

import Foundation

final class NetworkServiceDelegate: NSObject, URLSessionTaskDelegate {
    private let queue = DispatchQueue(label: "com.ristock.networkservice.delegate", attributes: .concurrent)
    private var progressHandlers: [Int: (Double) -> Void] = [:]
    private var fileNames: [Int: String] = [:]

    func setProgressHandler(_ handler: @escaping (Double) -> Void, fileName: String, for task: URLSessionTask) {
        queue.async(flags: .barrier) {
            self.progressHandlers[task.taskIdentifier] = handler
            self.fileNames[task.taskIdentifier] = fileName
        }
    }

    func removeProgressHandler(for task: URLSessionTask) {
        queue.async(flags: .barrier) {
            self.progressHandlers.removeValue(forKey: task.taskIdentifier)
            self.fileNames.removeValue(forKey: task.taskIdentifier)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard totalBytesExpectedToSend > 0 else { return }

        let progress = max(0, min(Double(totalBytesSent) / Double(totalBytesExpectedToSend), 1))

        var handler: ((Double) -> Void)?
        var fileName: String?

        queue.sync {
            handler = self.progressHandlers[task.taskIdentifier]
            fileName = self.fileNames[task.taskIdentifier]
        }

//        if let fileName = fileName {
//            NetworkLogger.logProgress(fileName: fileName, progress: progress)
//        }

        guard let handler = handler else { return }

        DispatchQueue.main.async {
            handler(progress)
        }
    }
}
