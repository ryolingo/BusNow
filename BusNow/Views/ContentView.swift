import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ClockViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            // ヘッダー部分
            VStack {
                Text("BusNow")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Text("次のバスまでの時間を確認しましょう")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)

            // 時計の表示
            ClockFaceView(viewModel: viewModel)
                .frame(height: 200)
                .padding(.horizontal)
            
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
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
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

#Preview {
    ContentView()
}
