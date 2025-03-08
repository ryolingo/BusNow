import Foundation

struct BusSchedule {
    static let departureTimes = [
        "08:14",
        "08:26",
        "08:42",
        "08:54",
        "09:10",
        "09:22",
        "09:38",
        "09:50",
        "10:06",
        "10:18",
        "10:34",
        "10:46",
        "11:02",
        "11:14",
        "11:30",
        "11:42",
        "11:58",
        "12:10",
        "12:26",
        "12:38",
        "12:54",
        "13:06",
        "13:22",
        "13:34",
        "13:50",
        "14:02",
        "14:18",
        "14:30",
        "14:46",
        "14:58",
        "15:14",
        "15:00",
        "15:01",
        "15:12",
        "15:03",
        "15:29",
        "15:30",
        "15:34",
        "16:10",
        "16:22",
        "16:38",
        "16:50",
        "17:06",
        "17:18",
        "17:34",
        "17:46",
        "18:02",
        "18:14",
        "18:30",
        "18:42",
        "18:58",
        "19:10",
        "19:26",
        "19:38",
    ]
    
    static func getUpcomingBusTimes(from currentTime: Date, withinHours: Double = 1.0) -> [Date] {
        let calendar = Calendar.current
        let endTime = calendar.date(byAdding: .hour, value: Int(withinHours), to: currentTime)!
        
        let currentHour = calendar.component(.hour, from: currentTime)
        let currentMinute = calendar.component(.minute, from: currentTime)
        
        return departureTimes.compactMap { timeStr -> Date? in
            guard let busTime = convertToDate(timeStr: timeStr) else { return nil }
            
            let busHour = calendar.component(.hour, from: busTime)
            let busMinute = calendar.component(.minute, from: busTime)
            
            let currentTotalMinutes = currentHour * 60 + currentMinute
            let busTotalMinutes = busHour * 60 + busMinute
            
            if busTotalMinutes >= currentTotalMinutes &&
               busTotalMinutes <= currentTotalMinutes + Int(withinHours * 60) {
                return calendar.date(bySettingHour: busHour,
                                   minute: busMinute,
                                   second: 0,
                                   of: currentTime)
            }
            return nil
        }
    }
    
    static func convertToDate(timeStr: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: timeStr)
    }
    
    static func getMinutes(from date: Date) -> Int {
        return Calendar.current.component(.minute, from: date)
    }
} 
