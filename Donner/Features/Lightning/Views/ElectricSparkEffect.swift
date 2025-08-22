import SwiftUI

struct ElectricSparkEffect: View {
  @State private var sparks: [Spark] = []
  let trigger: Int

  var body: some View {
    ZStack {
      ForEach(sparks) { spark in
        SparkView(
          spark: spark,
          onComplete: {
            removeSpark(id: spark.id)
          })
      }
    }
    .onChange(of: trigger) { _, _ in
      createSparks()
    }
  }

  private func createSparks() {
    for _ in 0..<32 {
      let spark = Spark(
        id: UUID(),
        startAngle: Double.random(in: 0...360),
        distance: Double.random(in: 60...120),
        size: Double.random(in: 1...5),
        duration: Double.random(in: 0.4...0.7),
        delay: Double.random(in: 0...0.1)
      )
      sparks.append(spark)
    }
  }

  private func removeSpark(id: UUID) {
    sparks.removeAll { $0.id == id }
  }
}

struct Spark: Identifiable {
  let id: UUID
  let startAngle: Double
  let distance: Double
  let size: Double
  let duration: Double
  let delay: Double
}

struct SparkView: View {
  let spark: Spark
  let onComplete: () -> Void
  @State private var isAnimating = false
  @State private var opacity: Double = 1.0

  private var endPosition: CGSize {
    let radians = spark.startAngle * .pi / 180
    return CGSize(
      width: cos(radians) * spark.distance,
      height: sin(radians) * spark.distance
    )
  }

  var body: some View {
    Circle()
      .fill(
        LinearGradient(
          colors: [
            Color.white,
            Color.donnerLightning,
            Color.donnerLightningGlow,
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .frame(width: spark.size, height: spark.size)
      .opacity(opacity)
      .offset(
        x: isAnimating ? endPosition.width : 0,
        y: isAnimating ? endPosition.height : 0
      )
      .blur(radius: isAnimating ? 1 : 0)
      .shadow(color: .donnerLightning, radius: 2)
      .onAppear {
        withAnimation(
          .easeOut(duration: spark.duration)
            .delay(spark.delay)
        ) {
          isAnimating = true
          opacity = 0
        }

        // Remove this spark after its animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + spark.duration + spark.delay + 0.1) {
          onComplete()
        }
      }
  }
}
