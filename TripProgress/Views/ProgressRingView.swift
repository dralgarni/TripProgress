import SwiftUI

struct ProgressRingView: View {
    let fraction: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), style: StrokeStyle(lineWidth: 20, lineCap: .round))

            Circle()
                .trim(from: 0, to: min(max(fraction, 0), 1))
                .stroke(
                    AngularGradient(colors: [.blue, .green, .blue], center: .center),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.5, dampingFraction: 0.85), value: fraction)
        }
        .accessibilityLabel("شريط تقدم الرحلة")
        .accessibilityValue("\(Int((fraction * 100).rounded()))%")
    }
}
