import Foundation
import Combine
import SwiftUI
import UserNotifications

class ClockViewModel: ObservableObject {
    @Published var currentTime = Date()
    @Published var upcomingBusTimes: [Date] = []
    private var timer: Timer?
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        requestNotificationPermission()
        startTimer()
        updateUpcomingBuses()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("通知が許可されました")
            } else if let error = error {
                print("通知の許可に失敗しました: \(error.localizedDescription)")
            }
        }
    }
    
    private func startTimer() {
        // 1分ごとに更新
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.currentTime = Date()
            self?.updateUpcomingBuses()
        }
    }
    
    func updateUpcomingBuses() {
        upcomingBusTimes = BusSchedule.getUpcomingBusTimes(from: currentTime)
        scheduleNotifications()
    }
    
    private func scheduleNotifications() {
        // 既存の通知をすべて削除
        notificationCenter.removeAllPendingNotificationRequests()
        
        // 次のバスの時間に通知をセット
        for busTime in upcomingBusTimes {
            let tenMinutesBefore = busTime.addingTimeInterval(-600) // 10分前
            
            // 現在時刻より後の場合のみ通知をスケジュール
            if tenMinutesBefore > currentTime {
                let content = UNMutableNotificationContent()
                content.title = "バスの出発10分前です"
                content.body = "次のバスは\(formattedTime(from: busTime))に出発します"
                content.sound = .default
                
                // 通知のトリガーを作成
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: tenMinutesBefore)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
                // 通知リクエストを作成
                let request = UNNotificationRequest(
                    identifier: "BusNotification-\(busTime.timeIntervalSince1970)",
                    content: content,
                    trigger: trigger
                )
                
                // 通知をスケジュール
                notificationCenter.add(request) { error in
                    if let error = error {
                        print("通知の設定に失敗しました: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func getMarkerStyle(for minute: Int) -> (length: CGFloat, color: Color) {
        let upcomingBusMinutes = upcomingBusTimes.map { BusSchedule.getMinutes(from: $0) }
        
        if upcomingBusMinutes.contains(minute) {
            return (CGFloat(20), Color.red)
        }
        
        let length = minute % 5 == 0 ? CGFloat(15) : CGFloat(10)
        return (length, Color.gray)
    }
    
    func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
