import SwiftUI
import Foundation

// MARK: - BusSchedule Model
struct BusSchedule {
    static let departureTimes = [
        "08:14", "08:26", "08:42", "08:54", "09:10", "09:22", "09:38", "09:50", "10:06",
        "10:18", "10:34", "10:46", "11:02", "11:14", "11:30", "11:42", "11:58", "12:10",
        "12:26", "12:38", "12:54", "13:06", "13:22", "13:34", "13:50", "14:02", "14:18",
        "14:30", "14:46", "14:58", "15:14", "15:00", "15:01", "15:12", "15:03", "15:29",
        "15:30", "15:34", "16:10", "16:22", "16:38", "16:50", "17:06", "17:18", "17:34",
        "17:46", "18:02", "18:14", "18:30", "18:42", "18:58", "19:10", "19:26", "19:38",
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
    
    static func convertTimeToString(hour: Int, minute: Int) -> String {
        return String(format: "%02d:%02d", hour, minute)
    }
    
    static func getMinutes(from date: Date) -> Int {
        return Calendar.current.component(.minute, from: date)
    }
}

// MARK: - View Model
class ClockViewModel: ObservableObject {
    @Published var currentTime = Date()
    @Published var upcomingBusTimes: [Date] = []
    @Published var customTime: Date?
    @Published var isUsingCustomTime = false
    
    private var timer: Timer?
    
    init() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime = Date()
            
            if !self.isUsingCustomTime {
                self.updateUpcomingBusTimes()
            }
        }
        
        updateUpcomingBusTimes()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func updateUpcomingBusTimes() {
        let timeToUse = isUsingCustomTime ? (customTime ?? Date()) : currentTime
        upcomingBusTimes = BusSchedule.getUpcomingBusTimes(from: timeToUse, withinHours: 2.0)
    }
    
    func setCustomTime(hour: Int, minute: Int) {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        customTime = calendar.date(from: components)
        isUsingCustomTime = true
        updateUpcomingBusTimes()
    }
    
    func useCurrentTime() {
        isUsingCustomTime = false
        updateUpcomingBusTimes()
    }
    
    // Get marker style based on position
    func getMarkerStyle(for minute: Int) -> MarkerStyle {
        if minute % 5 == 0 {
            // Hour marker
            return MarkerStyle(length: 12, width: 3, color: Color.primary)
        } else {
            // Minute marker
            return MarkerStyle(length: 6, width: 1, color: Color.primary.opacity(0.7))
        }
    }
    
    func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func timeUntilNextBus(from date: Date) -> String {
        guard let nextBus = upcomingBusTimes.first else {
            return "情報なし"
        }
        
        let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: date, to: nextBus)
        let hours = diffComponents.hour ?? 0
        let minutes = diffComponents.minute ?? 0
        
        if hours > 0 {
            return "\(hours)時間\(minutes)分後"
        } else {
            return "\(minutes)分後"
        }
    }
}

// MARK: - Utility Models
struct MarkerStyle {
    let length: CGFloat
    let width: CGFloat
    let color: Color
}

enum HandType {
    case hour, minute, second
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Clock Hand View
struct ClockHand: View {
    let date: Date
    let color: Color
    let handType: HandType
    
    private var rotation: Double {
        let calendar = Calendar.current
        let hour = Double(calendar.component(.hour, from: date) % 12)
        let minute = Double(calendar.component(.minute, from: date))
        let second = Double(calendar.component(.second, from: date))
        
        switch handType {
        case .hour:
            return (hour + minute / 60) * 30 // 30 degrees per hour
        case .minute:
            return (minute + second / 60) * 6 // 6 degrees per minute
        case .second:
            return second * 6 // 6 degrees per second
        }
    }
    
    private var handProperties: (length: CGFloat, width: CGFloat, offset: CGFloat) {
        switch handType {
        case .hour:
            return (length: 60, width: 4, offset: 20)
        case .minute:
            return (length: 80, width: 3, offset: 20)
        case .second:
            return (length: 85, width: 1.5, offset: 20)
        }
    }
    
    var body: some View {
        let properties = handProperties
        
        ZStack {
            // Hand
            RoundedRectangle(cornerRadius: properties.width / 2)
                .fill(color)
                .frame(width: properties.width, height: properties.length)
                .offset(y: -properties.length / 2 + properties.offset)
            
            // Decorative circle for second hand
            if handType == .second {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .offset(y: -properties.length / 2 + 15)
            }
        }
        .rotationEffect(.degrees(rotation))
        .animation(handType == .second ? .spring(response: 0.2, dampingFraction: 0.6) : .none, value: rotation)
    }
}

// MARK: - Clock Face View
struct ClockFaceView: View {
    @ObservedObject var viewModel: ClockViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background gradient
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: colorScheme == .dark
                                ? [Color(hex: "1E1E1E"), Color(hex: "2D2D2D")]
                                : [Color(hex: "F8F8F8"), Color(hex: "E8E8E8")]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            // Outer ring
            Circle()
                .stroke(
                    colorScheme == .dark ? Color(hex: "3A3A3A") : Color(hex: "CCCCCC"),
                    lineWidth: 4
                )
            
            // Inner decorative circle
            Circle()
                .stroke(
                    colorScheme == .dark ? Color(hex: "3A3A3A").opacity(0.5) : Color(hex: "DDDDDD"),
                    lineWidth: 1
                )
                .padding(30)
            
            // Hour numbers
            ForEach(1...12, id: \.self) { hour in
                Text("\(hour)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .position(
                        x: 100 + 80 * sin(Double(hour) * .pi / 6),
                        y: 100 - 80 * cos(Double(hour) * .pi / 6)
                    )
            }
            
            // Hour markers
            ForEach(0..<12, id: \.self) { hour in
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 3, height: 12)
                    .offset(y: -90)
                    .rotationEffect(.degrees(Double(hour) * 30))
            }
            
            // Minute markers
            ForEach(0..<60, id: \.self) { minute in
                if minute % 5 != 0 {
                    Rectangle()
                        .fill(Color.primary.opacity(0.5))
                        .frame(width: 1, height: 6)
                        .offset(y: -90)
                        .rotationEffect(.degrees(Double(minute) * 6))
                }
            }
            
            // Clock hands
            ClockHand(
                date: viewModel.isUsingCustomTime ? (viewModel.customTime ?? Date()) : viewModel.currentTime,
                color: Color.primary,
                handType: .hour
            )
            
            ClockHand(
                date: viewModel.isUsingCustomTime ? (viewModel.customTime ?? Date()) : viewModel.currentTime,
                color: Color.primary,
                handType: .minute
            )
            
            if !viewModel.isUsingCustomTime {
                ClockHand(
                    date: viewModel.currentTime,
                    color: Color(hex: "E63946"),
                    handType: .second
                )
            }
            
            // Center decoration
            Circle()
                .fill(Color(hex: "E63946"))
                .frame(width: 10, height: 10)
            
            Circle()
                .stroke(Color.primary, lineWidth: 2)
                .frame(width: 14, height: 14)
        }
        .frame(width: 200, height: 200)
    }
}

// MARK: - Time Input View
struct TimeInputView: View {
    @ObservedObject var viewModel: ClockViewModel
    @State private var selectedHour = 8
    @State private var selectedMinute = 0
    
    let hours = Array(0...23)
    let minutes = Array(0...59)
    
    var body: some View {
        VStack(spacing: 20) {
            Text("時刻をカスタマイズ")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text("バス時刻を確認したい時間を選択してください")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom)
            
            HStack(spacing: 15) {
                // 時間選択
                VStack {
                    Text("時")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Picker("Hour", selection: $selectedHour) {
                        ForEach(hours, id: \.self) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100, height: 150)
                    .clipped()
                }
                
                Text(":")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                // 分選択
                VStack {
                    Text("分")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Picker("Minute", selection: $selectedMinute) {
                        ForEach(minutes, id: \.self) { minute in
                            Text(String(format: "%02d", minute)).tag(minute)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100, height: 150)
                    .clipped()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            .padding()
            
            // 選択された時刻の表示
            Text(String(format: "選択時刻: %02d:%02d", selectedHour, selectedMinute))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            
            // 設定ボタン
            Button(action: {
                viewModel.setCustomTime(hour: selectedHour, minute: selectedMinute)
            }) {
                Text("この時刻のバス時間を確認")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
                    .padding(.horizontal)
            }
            
            // 現在時刻に戻るボタン
            Button(action: {
                viewModel.useCurrentTime()
            }) {
                Text("現在時刻に戻る")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.vertical, 10)
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            // 現在の時刻を初期値に設定
            let calendar = Calendar.current
            
            if viewModel.isUsingCustomTime, let customTime = viewModel.customTime {
                selectedHour = calendar.component(.hour, from: customTime)
                selectedMinute = calendar.component(.minute, from: customTime)
            } else {
                let now = Date()
                selectedHour = calendar.component(.hour, from: now)
                selectedMinute = calendar.component(.minute, from: now)
            }
        }
    }
}

// MARK: - Home View (Bus Schedule View)
struct HomeView: View {
    @ObservedObject var viewModel: ClockViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // ヘッダー部分
            VStack {
                Text("BusNow")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                if viewModel.isUsingCustomTime {
                    Text("カスタム時刻のバス情報")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.orange.opacity(0.2))
                        )
                } else {
                    Text("次のバスまでの時間を確認しましょう")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 20)
            
            // 時計の表示
            ClockFaceView(viewModel: viewModel)
                .padding(.horizontal)
            
            // 時刻表示
            Text(viewModel.formattedTime(from: viewModel.isUsingCustomTime ? (viewModel.customTime ?? Date()) : viewModel.currentTime))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.top, 8)
            
            Spacer()
            
            // 次のバスの時刻をカードで表示
            if let nextBus = viewModel.upcomingBusTimes.first {
                VStack {
                    Text("次のバス")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(viewModel.formattedTime(from: nextBus))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(viewModel.timeUntilNextBus(from: viewModel.isUsingCustomTime ? (viewModel.customTime ?? Date()) : viewModel.currentTime))
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
                        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
            } else {
                VStack {
                    Text("本日のバスはすべて終了しました")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("明日のスケジュールをご確認ください")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray)
                        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
            }
            
            // 次のバス時刻のリスト
            VStack(alignment: .leading, spacing: 8) {
                Text("今後のバス時刻")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                if viewModel.upcomingBusTimes.isEmpty {
                    Text("本日の運行は終了しました")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(viewModel.upcomingBusTimes, id: \.self) { time in
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.blue)
                                    
                                    Text(viewModel.formattedTime(from: time))
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if let customTime = viewModel.isUsingCustomTime ? viewModel.customTime : viewModel.currentTime {
                                        let diffComponents = Calendar.current.dateComponents([.minute], from: customTime, to: time)
                                        if let minutes = diffComponents.minute, minutes >= 0 {
                                            Text("\(minutes)分後")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 3)
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                startPoint: .top, endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
}

// MARK: - Main Content View with Tab Navigation
struct ContentView: View {
    @StateObject private var viewModel = ClockViewModel()
    
    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("バス時刻", systemImage: "clock")
                }
            
            TimeInputView(viewModel: viewModel)
                .tabItem {
                    Label("時刻設定", systemImage: "timer")
                }
        }
        .accentColor(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
