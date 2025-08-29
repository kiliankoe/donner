import CoreLocation
import SwiftUI

struct ConnectionLine: View {
  let from: CLLocation
  let to: CLLocation
  let opacity: Double

  var body: some View {
    GeometryReader { geometry in
      Path { path in
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 10, y: 10))
      }
      .stroke(
        Color.donnerLightning.opacity(opacity * 0.5),
        style: StrokeStyle(lineWidth: 1, dash: [5, 3])
      )
    }
  }
}
