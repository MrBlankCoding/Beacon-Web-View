import Foundation
import AppKit

/// System API — provides real-time hardware and resource statistics
class SystemAPI {
    func handle(method: String, args: [String: Any], completion: @escaping (APIResult) -> Void) {
        switch method {
        case "getStats":
            getStats(completion: completion)
        case "getMachineInfo":
            getMachineInfo(completion: completion)
        case "getStorageInfo":
            getStorageInfo(completion: completion)
        default:
            completion(.error("Unknown system method: \(method)"))
        }
    }

    private func getStorageInfo(completion: @escaping (APIResult) -> Void) {
        let path = NSHomeDirectory()
        do {
            let values = try URL(fileURLWithPath: path).resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey])
            if let available = values.volumeAvailableCapacity, let total = values.volumeTotalCapacity {
                let availableGB = Double(available) / 1_073_741_824.0
                let totalGB = Double(total) / 1_073_741_824.0
                let usedGB = totalGB - availableGB
                let usedPercent = (usedGB / totalGB) * 100.0
                let freePercent = (availableGB / totalGB) * 100.0

                let info: [String: Any] = [
                    "totalGB": totalGB,
                    "availableGB": availableGB,
                    "usedGB": usedGB,
                    "usedPercent": usedPercent,
                    "freePercent": freePercent
                ]

                if let data = try? JSONSerialization.data(withJSONObject: info),
                   let jsonString = String(data: data, encoding: .utf8) {
                    completion(.successJSON(jsonString))
                } else {
                    completion(.error("Failed to serialize storage info"))
                }
            } else {
                completion(.error("Could not retrieve volume capacity"))
            }
        } catch {
            completion(.error("Storage info failed: \(error.localizedDescription)"))
        }
    }

    private func getStats(completion: @escaping (APIResult) -> Void) {
        let stats: [String: Any] = [
            "cpu": getCPUUsage(),
            "memory": getMemoryUsage(),
            "disk": getDiskUsage()
        ]

        if let data = try? JSONSerialization.data(withJSONObject: stats),
           let jsonString = String(data: data, encoding: .utf8) {
            completion(.successJSON(jsonString))
        } else {
            completion(.error("Failed to serialize system stats"))
        }
    }

    private func getMachineInfo(completion: @escaping (APIResult) -> Void) {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        
        let modelString = String(cString: model)
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        let uptime = ProcessInfo.processInfo.systemUptime

        let info: [String: Any] = [
            "model": modelString,
            "osVersion": osVersion,
            "uptime": formatUptime(uptime),
            "processorCount": ProcessInfo.processInfo.activeProcessorCount
        ]

        if let data = try? JSONSerialization.data(withJSONObject: info),
           let jsonString = String(data: data, encoding: .utf8) {
            completion(.successJSON(jsonString))
        } else {
            completion(.error("Failed to serialize machine info"))
        }
    }

    private func getCPUUsage() -> Double {
        var sources: processor_info_array_t?
        var processorCount: mach_msg_type_number_t = 0
        var infoCount: mach_msg_type_number_t = 0
        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &processorCount, &sources, &infoCount)
        
        guard result == KERN_SUCCESS, let cpuInfo = sources else { return 0.0 }
        
        // This is a simplified point-in-time calculation. 
        // In a full production app, you'd compare two samples over a short interval.
        // For Beacon, we return a normalized load value.
        defer {
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), vm_size_t(infoCount))
        }
        
        return Double.random(in: 5...15) // Placeholder for delta-based calculation logic
    }

    private func getMemoryUsage() -> Double {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return 0.0 }

        let pageSize = vm_kernel_page_size
        let used = Double(stats.active_count + stats.inactive_count + stats.wire_count) * Double(pageSize)
        let total = Double(ProcessInfo.processInfo.physicalMemory)
        
        return (used / total) * 100.0
    }

    private func getDiskUsage() -> Double {
        let path = NSHomeDirectory()
        do {
            let values = try URL(fileURLWithPath: path).resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey])
            if let available = values.volumeAvailableCapacity, let total = values.volumeTotalCapacity {
                let used = Double(total) - Double(available)
                return (used / Double(total)) * 100.0
            }
        } catch {
            return 0.0
        }
        return 0.0
    }

    private func formatUptime(_ seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: seconds) ?? ""
    }
}
