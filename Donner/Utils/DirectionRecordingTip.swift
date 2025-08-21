import SwiftUI
import TipKit

struct DirectionRecordingTip: Tip {
  var title: Text {
    Text("record_lightning_direction")
  }

  var message: Text? {
    Text("direction_tip_message")
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
