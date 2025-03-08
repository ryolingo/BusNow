import SwiftUI
//アナログ時計のUIの部分
struct ClockFaceView: View {
    @ObservedObject var viewModel: ClockViewModel
    
    var body: some View {
        ZStack {
            // 時計の文字盤
            Circle()
                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                .frame(width: 200, height: 200)
            
            // 時間のメモリ
            ForEach(0..<60) { minute in
                let style = viewModel.getMarkerStyle(for: minute)
                Rectangle()
                    .fill(style.color)
                    .frame(width: 2, height: style.length)
                    .offset(y: -90 + style.length / 2)
                    .rotationEffect(.degrees(Double(minute) * 6))
            }
            
            // 現在時刻の針
            ClockHand(date: viewModel.currentTime, color: .blue, handType: .hour)
            ClockHand(date: viewModel.currentTime, color: .blue, handType: .minute)
        }
        .padding()
    }
}

#Preview {
    ClockFaceView(viewModel: ClockViewModel())
}
