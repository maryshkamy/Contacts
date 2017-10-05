//
//  SessionManager.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 05/10/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation

struct SessionManager {
    static let shared = SessionManager()
    
    var sessionConfiguration: URLSessionConfiguration {
        let cfg = URLSessionConfiguration.default
        cfg.allowsCellularAccess = true
        cfg.networkServiceType = .default
        cfg.requestCachePolicy = .returnCacheDataElseLoad
        cfg.isDiscretionary = true
        cfg.urlCache = URLCache(memoryCapacity: 2048, diskCapacity: 10240, diskPath: NSTemporaryDirectory())
        return cfg
    }

    var operationQueue: OperationQueue {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 5
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        return queue
    }
}
