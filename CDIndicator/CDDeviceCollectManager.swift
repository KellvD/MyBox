//
//  CDDeviceCollectManager.swift
//  CDTextViewDemo
//
//  Created by changdong on 2020/12/2.
//  Copyright © 2019 changdong. All rights reserved.
//

import UIKit
import MachO
import SystemConfiguration
import CoreTelephony
class CDDeviceCollectManager: NSObject {
    lazy var _device: UIDevice = {
        let dev = UIDevice.current
        return dev
    }()
    
    //设备名称
    @objc func getPhoneName()->String{
        return _device.name
    }
    
    //设备版本13.3
    @objc func getModelVersion()->String{
        return _device.systemVersion
    }
    
    @objc func getUUID()->String{
        return _device.identifierForVendor!.uuidString
    }
    
    //型号名称 iPhone8
    @objc func getModelName()->String{
        return CDDeviceConfig.getPhoneName()
    }
    
    //在线时长
    @objc func getPowerOnTime()->String{
        return String(format: "%.0fmin", ProcessInfo.processInfo.systemUptime / 60.0)
    }
    
    //电池电量
    @objc func getPowerRate()->String{
        _device.isBatteryMonitoringEnabled = true
        return String(format: "%.0f%%", _device.batteryLevel * 100)
    }
    
    //是否开启省电模式
    @objc func getPoweraSaveModel() -> String {
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            return "打开"
        }else{
            return "关闭"
        }
    }
    
    //CPU
    @objc func getCpuState()->String{
        return CDCpuManager.cpuUsage().user
    }
    
    ///获取cpu核数类型
    @objc func getCpuCount() -> String {
        return CDCpuManager.cpuCount()
    }
    
    /// 获取当前网络类型
    @objc func getNetWorkName()->String{
        let status = CDReachability.networkType()
        if status == .Unknow {
            return "无网络"
        }else if status == .WLAN{
            return CDReachability.wifiName()
        }else{
            return CDReachability.carrierName()
        }
    }
    
    /// 获取当前设备IP
    @objc func getIP() -> String {
        return CDReachability.IP()
    }
    
    /// 获取运营商
    @objc func getNetworkCarrier() -> String {
        return CDReachability.carrierName()
    }
    
    
    //内存
    @objc func getMemoryRate()->String{
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usage = info.resident_size
            let total = ProcessInfo.processInfo.physicalMemory
//            print("usage = ",fileSizeToString(fileSize: Int64(usage)))
//            print("total = ", fileSizeToString(fileSize: Int64(total)))
            let ratio = Double(usage) / Double(total)
            return String(format: "%.0f%%", ratio * 100)
        }
       
        return ""
       
    }
    
    /// 磁盘总大小
    @objc func getTotalDiskSize() -> String {
        var fs = blankof(type: statfs.self)
        if statfs("/var",&fs) >= 0{
            let size = Int64(UInt64(fs.f_bsize) * fs.f_blocks)
            return fileSizeToString(fileSize: size)
        }
        return "0B"
    }
    
    /// 磁盘可用大小
    @objc func getAvailableDiskSize() -> String {
        var fs = blankof(type: statfs.self)
        if statfs("/var",&fs) >= 0{
            return fileSizeToString(fileSize: Int64(UInt64(fs.f_bsize) * fs.f_bavail))
        }
        return "0B"
    }
    
    /// 将大小转换成字符串用以显示
    private func fileSizeToString(fileSize:Int64) -> String {
        
        let fileSize1 = CGFloat(fileSize)
        let KB:CGFloat = 1024
        let MB:CGFloat = KB*KB
        let GB:CGFloat = MB*KB
        if fileSize < 10 {
            return "0 B"
        } else if fileSize1 < KB {
            return "< 1 KB"
        } else if fileSize1 < MB {
            return String(format: "%.1f KB", CGFloat(fileSize1)/KB)
        } else if fileSize1 < GB {
            return String(format: "%.1f MB", CGFloat(fileSize1)/MB)
        } else {
            return String(format: "%.1f GB", CGFloat(fileSize1)/GB)
        }
    }
    
    private func blankof<T>(type:T.Type) -> T {
        let ptr = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T>.size)
        let val = ptr.pointee
        return val
    }
}



