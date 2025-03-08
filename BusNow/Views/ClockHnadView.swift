import SwiftUI
//時計の針の"動きを定義している部分"
struct ClockHand: View {
    let date: Date
    let color: Color
    let handType: HandType
    
    enum HandType {
        case hour
        case minute
    }
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                path.move(to: center)
                
                let angle = getAngle(date: date, handType: handType)
                let handLength: CGFloat = handType == .hour ? 50 : 70
                
                let endPoint = CGPoint(
                    x: center.x + handLength * sin(angle),
                    y: center.y - handLength * cos(angle)
                )
                
                path.addLine(to: endPoint)
            }
            .stroke(color, lineWidth: handType == .hour ? 3 : 2)
        }
    }
    
    private func getAngle(date: Date, handType: HandType) -> Double {
        let calendar = Calendar.current
        
        switch handType {
        case .hour:
            let hour = Double(calendar.component(.hour, from: date) % 12)
            let minute = Double(calendar.component(.minute, from: date))
            return ((hour + minute / 60) / 12) * (2 * .pi)
        case .minute:
            let minute = Double(calendar.component(.minute, from: date))
            return (minute / 60) * (2 * .pi)
        }
    }
}

#Preview {
    ClockHand(date: Date(), color: .black, handType: .hour)
        .frame(width: 200, height: 200)
}
