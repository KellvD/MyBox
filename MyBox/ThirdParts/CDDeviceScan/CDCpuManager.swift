//
//  CDCpuManager.swift
//  CDTextViewDemo
//
//  Created by changdong cwx889303 on 2020/12/4.
//  Copyright © 2020 (c) Huawei Technologies Co., Ltd. 2012-2019. All rights reserved.
//

import UIKit
import MachO
import SystemConfiguration

class CDCpuManager: NSObject {

    private class func hostCPULoadInfo()->host_cpu_load_info?{
        let HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info>.stride/MemoryLayout<integer_t>.stride
        var size = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
        var cpuLoadInfo = host_cpu_load_info()
        let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: HOST_CPU_LOAD_INFO_COUNT) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
                
            }
            
        }
        if result != KERN_SUCCESS{
            print("Error  - \\(#file): \\(#function) - kern_result_t = \\(result)")
            return nil
        }
        return cpuLoadInfo
    }
    
    public class func cpuUsage() -> (system: String, user: String, idle : String, nice: String){
        let loadPrevious = hostCPULoadInfo()
        sleep(1)
        let load = hostCPULoadInfo()
        if loadPrevious == nil || load == nil {
            return ("", "", "", "");
        }
        let usrDiff: Double = Double(load!.cpu_ticks.0 - loadPrevious!.cpu_ticks.0);
        let systDiff = Double(load!.cpu_ticks.1 - loadPrevious!.cpu_ticks.1);
        let idleDiff = Double(load!.cpu_ticks.2 - loadPrevious!.cpu_ticks.2);
        let niceDiff = Double(load!.cpu_ticks.3 - loadPrevious!.cpu_ticks.3);
        let totalTicks = usrDiff + systDiff + idleDiff + niceDiff
        let sys = String(format: "%.0f%%", systDiff / totalTicks * 100.0)
        let usr = String(format: "%.0f%%", usrDiff / totalTicks * 100.0)
        let idle = String(format: "%.0f%%", idleDiff / totalTicks * 100.0)
        let nice = String(format: "%.0f%%", niceDiff / totalTicks * 100.0)
        return (sys, usr, idle, nice);
    }
    
    public class func cpuCount() -> String {
        var ncpu: UInt = UInt(0)
        var len: size_t = MemoryLayout.size(ofValue: ncpu)
        sysctlbyname("hw.ncpu", &ncpu, &len, nil, 0)
        return "\(Int(ncpu))"
    }
}
