import SwiftUI
import TipKit

struct DirectionRecordingTip: Tip {
  var title: Text {
    Text("Record Lightning Direction")
  }

  var message: Text? {
    Text(
      "Tap to point your device toward where you saw the lightning. This helps estimate the strike's location on a map."
    )
  }

  var image: Image? {
    Image(systemName: "location.north.line.fill")
  }

  var options: [TipOption] {
    [
      Tips.MaxDisplayCount(3),
      Tips.IgnoresDisplayFrequency(false),
    ]
  }
}
