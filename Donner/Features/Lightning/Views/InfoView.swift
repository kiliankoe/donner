import SwiftUI

struct InfoView: View {
  @Binding var isPresented: Bool

  private var appDisplayName: String {
    Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
      ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
      ?? "Donner"
  }

  private var appVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
  }

  private var buildNumber: String {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
  }

  var body: some View {
    NavigationView {
      VStack(spacing: 30) {
        VStack(spacing: 12) {
          Image(systemName: "bolt.fill")
            .font(.system(size: 60))
            .foregroundStyle(LinearGradient.donnerLightningGradient)
            .glow(radius: 10)

          Text(appDisplayName)
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(Color.donnerTextPrimary)

          Text(
            String(
              format: NSLocalizedString("version_format", comment: "App version format"),
              appVersion, buildNumber)
          )
          .font(.footnote)
          .foregroundStyle(Color.donnerTextSecondary)
        }
        .padding(.top, 20)

        VStack(spacing: 20) {
          InfoButton(
            image: "chevron.left.forwardslash.chevron.right",
            title: NSLocalizedString("open_source", comment: "Open source"),
            linkText: "github.com/kiliankoe/donner",
            url: URL(string: "https://github.com/kiliankoe/donner")!
          )
          InfoButton(
            image: "at",
            title: NSLocalizedString("mastodon", comment: "Mastodon"),
            linkText: "@kilian@chaos.social",
            url: URL(string: "https://chaos.social/@kilian")!
          )
          InfoButton(
            image: "mail",
            title: NSLocalizedString("email", comment: "Email"),
            linkText: "donner@kilian.io",
            url: URL(string: "mailto:donner@kilian.io")!
          )
        }
        .padding(.horizontal)

        Spacer()

        Text("built_with_love")
          .font(.caption)
          .foregroundStyle(Color.donnerTextSecondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            isPresented = false
          } label: {
            Image(systemName: "xmark.circle.fill")
              .font(.title2)
              .symbolRenderingMode(.hierarchical)
              .foregroundStyle(Color.donnerTextSecondary)
          }
        }
      }
      .background(Color.donnerBackground)
    }
  }
}

struct InfoButton: View {
  let image: String
  let title: String
  let linkText: String
  let url: URL

  var body: some View {
    Link(destination: url) {
      HStack {
        Image(systemName: image)
          .font(.title3)
          .frame(width: 40)
        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.body.weight(.medium))
          Text(linkText)
            .font(.caption)
            .foregroundStyle(Color.donnerTextSecondary)
        }
        Spacer()
        Image(systemName: "arrow.up.right.square")
          .font(.caption)
          .foregroundStyle(Color.donnerTextSecondary)
      }
      .padding()
      .background(Color.donnerSurfaceSecondary)
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .buttonStyle(.plain)
  }
}
