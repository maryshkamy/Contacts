//
//  UIViewController+ActiveLoadView.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 01/11/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var isOnline: Bool {
        let status = Reachability.networkReachabilityForInternetConnection()?.currentReachabilityStatus
        switch status {
        case .notReachable?:
            return false
        default:
            return true
        }
    }
}
