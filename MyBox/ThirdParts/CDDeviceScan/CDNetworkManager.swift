//
//  CDNetworkManager.swift
//  CDTextViewDemo
//
//  Created by changdong cwx889303 on 2020/12/9.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import Foundation

import CoreTelephony
import SystemConfiguration.CaptiveNetwork
class CDNetworkManager: NSObject {
    
    //运营商名称
    public class func carrierName() -> String {
           let info = CTTelephonyNetworkInfo()
           var supplier:String = ""
           if #available(iOS 12.0, *) {
               let network = getNetworkType(typeString: info.serviceCurrentRadioAccessTechnology!.values.first!)
               if let carriers = info.serviceSubscriberCellularProviders {
                   if carriers.keys.count == 0 {
                       return "无sim卡"
                   } else { //获取运营商信息
                       for (index, carrier) in carriers.values.enumerated() {
                           guard carrier.carrierName != nil else { return "无sim卡" }
                           //查看运营商信息 通过CTCarrier类
                           if index == 0 {
                               supplier = carrier.carrierName! + " " + network
                           } else {
                              supplier = supplier + "," + carrier.carrierName! + " " + network
                           }
                       }
                       return supplier
                   }
               } else{
                   return "无sim卡"
               }
           } else {
               if let carrier = info.subscriberCellularProvider {
                    let network = getNetworkType(typeString: info.currentRadioAccessTechnology!)
                   guard carrier.carrierName != nil else { return "无sim卡" }
                   return carrier.carrierName! + " " + network
               } else{
                   return "无sim卡"
               }
           }
       }

       private class func getNetworkType(typeString:String)->String{
           switch typeString {
           case CTRadioAccessTechnologyLTE:
              return "4G"
               case CTRadioAccessTechnologyGPRS,CTRadioAccessTechnologyEdge:
               return "2G"
           default:
              return "3G"
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
}
