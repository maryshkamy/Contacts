//
//  Reachability.swift
//  Contacts
//
//  Created by Mariana Rios Silveira Carvalho on 01/10/17.
//  Copyright © 2017 Mariana Rios Silveira Carvalho. All rights reserved.
//

import Foundation
import SystemConfiguration

enum ReachabilityStatus: CustomStringConvertible {
    case notReachable
    case reachableViaWiFi
    case reachableViaWWAN

    var description: String {
        switch self {
        case .notReachable: return "Sem internet"
        case .reachableViaWiFi: return "Conectado via Wi-Fi"
        case .reachableViaWWAN: return "Conectado via Rede Celular"
        }
    }
}

let ReachabilityDidChangeNotificationName = Notification.Name(rawValue: "ReachabilityDidChangeNotification")

class Reachability: NSObject {
    private var networkReachability: SCNetworkReachability?
    private var notifying = false

    private var flags: SCNetworkReachabilityFlags {
        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        if let reachability = networkReachability, withUnsafeMutablePointer(to: &flags, { SCNetworkReachabilityGetFlags(reachability, UnsafeMutablePointer($0)) }) == true {
            return flags
        }
        else {
            return []
        }
    }

    var currentReachabilityStatus: ReachabilityStatus {
        if flags.contains(.reachable) == false {
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }

    private init?(withHost hostname: String? = "") {
        super.init()
        if let host = hostname {
            networkReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, NSString(string: host).utf8String!)
        }
        if networkReachability == nil {
            return nil
        }
    }

    private init?(withHostAddress hostAddress: sockaddr_in) {
        super.init()
        var address = hostAddress
        guard let defaultRouteReachability = withUnsafePointer(to: &address, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, $0)
            }
        }) else {
            return  nil
        }
        networkReachability = defaultRouteReachability
        if networkReachability == nil {
            return nil
        }
    }

    deinit {
        stopNotifier()
    }

    static func networkReachabilityForInternetConnection() -> Reachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        return Reachability(withHostAddress: zeroAddress)
    }

    static func networkReachabilityForLocalWiFi() -> Reachability? {
        var localWifiAddress = sockaddr_in()
        localWifiAddress.sin_len = UInt8(MemoryLayout.size(ofValue: localWifiAddress))
        localWifiAddress.sin_family = sa_family_t(AF_INET)
        localWifiAddress.sin_addr.s_addr = IN_LINKLOCALNETNUM

        return Reachability(withHostAddress: localWifiAddress)
    }

    func startNotifier() -> Bool {
        guard notifying == false else {
            return false
        }

        var context = SCNetworkReachabilityContext()
        context.info = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        guard let reachability = networkReachability, SCNetworkReachabilitySetCallback(reachability, { (target: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) in
            if let currentInfo = info {
                let infoObject = Unmanaged<AnyObject>.fromOpaque(currentInfo).takeUnretainedValue()
                if infoObject is Reachability {
                    let networkReachability = infoObject as! Reachability
                    NotificationCenter.default.post(name: ReachabilityDidChangeNotificationName, object: networkReachability)
                }
            }
        }, &context) == true else {
            return false
        }

        guard SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) == true else {
            return false
        }

        notifying = true
        return notifying
    }

    func stopNotifier() {
        if let reachability = networkReachability, notifying == true {
            SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode as! CFString)
            notifying = false
        }
    }
}
