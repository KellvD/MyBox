//
//  CDReachability.swift
//  SwiftApp
//
//  Created by changdong on 2021/8/11.
//

import UIKit
import CoreTelephony
import SystemConfiguration.CaptiveNetwork


enum NetworkStatus {
    case no
    case wifi
    case wwan
}

enum NetworkType {
    case Unknow
    case UTRAN
    case GERAN
    case WLAN
    case GAN
    case HSPA
    case EUTRAN
    case NR
}
let NoSIM = "无sim卡"
class CDReachability: NSObject {
    
    var reachabilityRe:SCNetworkReachability!
    
    init(hostName:String) {
        super.init()
        if let reachablity = SCNetworkReachabilityCreateWithName(nil, hostName) {
            self.reachabilityRe = reachablity
        }
    }
    
    public class func networkType() -> NetworkType {
        var type:NetworkType = .Unknow
        let str = CDReachability.networkTypeString()
        if str.contains("2") {
            type = .GERAN
        }else if str.contains("3") {
            type = .UTRAN
        }else if str.contains("4") {
            type = .EUTRAN
        }else if str.contains("5") {
            type = .NR
        }else if str.contains("WIFI") {
            type = .WLAN
        }else if str.contains("NO_NETWORK") {
            type = .Unknow
        }
        return type
    }
    //运营商名称
    
    public class func carrierName()->String{
        let info = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            
            let carriers = info.serviceSubscriberCellularProviders
            if carriers!.count > 0 {
                for (_, carrier) in carriers!.values.enumerated() {
                    guard carrier.carrierName != nil else { return "无sim卡" }
                    //查看运营商信息 通过CTCarrier类
                    return carrier.carrierName!
                }
            }else{
                return NoSIM
            }
        } else {
            if let carrier = info.subscriberCellularProvider {
                guard carrier.carrierName != nil else { return NoSIM }
                return carrier.carrierName!
            } else{
                return NoSIM
            }
            
        }
        return NoSIM
    }
    
    //IP
    public class func IP()->String{
        var addresses = [String]()
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        if let ipStr = addresses.first {
            return ipStr
        } else {
            return ""
        }
    }
    
    //Wifi 名称
    public class func wifiName()->String{
    
        var wifiName = ""
        let wifiInterfaces = CNCopySupportedInterfaces()
        if wifiInterfaces == nil{
            return wifiName
        } else {
            let interfacesArr = CFBridgingRetain(wifiInterfaces) as! Array<String>
            if interfacesArr.count > 0 {
                let interfaceName = interfacesArr.first! as CFString
                let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName)
                if ussafeInterfaceData != nil {
                 let interfaceData = ussafeInterfaceData as! Dictionary<String,Any>
                    wifiName = interfaceData["SSID"] as! String
                }
            }
            
        }
        return wifiName
    }
    
    func reachabilityStatus()->NetworkStatus{
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachabilityRe, &flags) {
            return reachabilityStatusForFlag(flags: flags)
        }
        return .no
    }
    
    private func reachabilityStatusForFlag(flags:SCNetworkReachabilityFlags) -> NetworkStatus{
        if (flags.rawValue & SCNetworkReachabilityFlags.reachable.rawValue) == 0 {
            return .no
        }
        
        if (flags.rawValue & SCNetworkReachabilityFlags.isWWAN.rawValue) == SCNetworkReachabilityFlags.isWWAN.rawValue {
            return .wwan
        }
        
        if (flags.rawValue & SCNetworkReachabilityFlags.connectionRequired.rawValue) == 0 {
            return .wifi
        }
        
        if ((flags.rawValue & SCNetworkReachabilityFlags.connectionOnDemand.rawValue) != 0 ||
            (flags.rawValue & SCNetworkReachabilityFlags.connectionOnTraffic.rawValue) != 0 ) &&
            (flags.rawValue & SCNetworkReachabilityFlags.interventionRequired.rawValue) == 0{
            return .wifi
        }
        
        return .no
        
    }
    
    private class func networkTypeString()->String{
        var str = "4G"
        let reach = CDReachability(hostName: "www.baidu.com")
        switch reach.reachabilityStatus() {
        case .no:
            str = "NO_NETWORK"
        case .wifi:
            str = "WIFI"
        case .wwan:
            let info = CTTelephonyNetworkInfo()
            var typeString:String
            if #available(iOS 12.0, *) {
                let network = info.serviceCurrentRadioAccessTechnology
                if network!.count > 0 {
                    typeString = network!.values.first!
                }else{
                    return "NO_NETWORK"
                }
                
            }else{
                typeString = info.currentRadioAccessTechnology!
            }
            
            switch typeString {
            case CTRadioAccessTechnologyGPRS:
                str =  "GPRS"
            case CTRadioAccessTechnologyeHRPD:
                str =  "HRPD"
            case CTRadioAccessTechnologyEdge,CTRadioAccessTechnologyCDMA1x:
                str =  "2G"
            case CTRadioAccessTechnologyWCDMA,CTRadioAccessTechnologyHSUPA,
                 CTRadioAccessTechnologyCDMAEVDORev0,CTRadioAccessTechnologyCDMAEVDORevA,
                 CTRadioAccessTechnologyCDMAEVDORevB,CTRadioAccessTechnologyHSDPA:
                str =  "3G"
                
            case CTRadioAccessTechnologyLTE:
                str =  "4G"
                
            default :
                if #available(iOS 14.1, *) {
                    if typeString == CTRadioAccessTechnologyNRNSA || typeString == CTRadioAccessTechnologyNR{
                        str =  "5G"
                    }
                }
            }
        }
        return str
    }
    
    
    
}
