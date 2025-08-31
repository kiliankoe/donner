import SwiftUI

struct InfoIconButton: View {
  @State private var showingInfo = false

  var body: some View {
    Button {
      showingInfo = true
    } label: {
      Image(systemName: "info.circle.fill")
        .font(.title)
        .symbolRenderingMode(.hierarchical)
        .foregroundStyle(Color.donnerTextSecondary)
    }
    .sheet(isPresented: $showingInfo) {
      InfoView(isPresented: $showingInfo)
    }
  }
}
