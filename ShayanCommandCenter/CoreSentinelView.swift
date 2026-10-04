import SwiftUI

// Core Sentinel security intelligence surface.
struct CoreSentinelView: View {
    @AppStorage("appLockEnabled") private var appLockEnabled = false
    @StateObject private var dashboardStatus = DashboardStatus()

    private var systemSecure: Bool {
        dashboardStatus.isOnline
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 10) {
                        Image(systemName: "shield.checkered")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.blue)
                        Text("CORE SENTINEL")
                            .font(.caption.weight(.bold))
                            .tracking(1.5)
                            .foregroundStyle(.blue)
                    }

                    Text("AI Security Intelligence")
                        .font(.largeTitle.bold())

                    Text("Your digital guardian for Shayan Core health and security signals.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    Circle()
                        .fill(systemSecure ? Color.green : Color.orange)
                        .frame(width: 12, height: 12)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(systemSecure ? "SYSTEM SECURE" : "ATTENTION REQUIRED")
                            .font(.headline.weight(.bold))
                            .tracking(0.7)
                        Text(systemSecure
                             ? "No known issues in currently monitored signals."
                             : "A monitored system signal needs attention.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(17)
                .background((systemSecure ? Color.green : Color.orange).opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke((systemSecure ? Color.green : Color.orange).opacity(0.22), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))

                VStack(alignment: .leading, spacing: 13) {
                    Text("SECURITY SIGNALS")
                        .font(.caption.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(.secondary)

                    SentinelSignalRow(
                        title: "App Protection",
                        subtitle: appLockEnabled ? "Face ID / passcode protection enabled" : "App lock is currently disabled",
                        icon: appLockEnabled ? "lock.shield.fill" : "lock.open",
                        isHealthy: appLockEnabled
                    )

                    SentinelSignalRow(
                        title: "Portfolio Endpoint",
                        subtitle: dashboardStatus.isOnline ? "Reachable and responding" : "Currently unavailable",
                        icon: "network",
                        isHealthy: dashboardStatus.isOnline
                    )

                    SentinelSignalRow(
                        title: "Secure Storage",
                        subtitle: "Protected Notes use iOS Keychain storage",
                        icon: "key.fill",
                        isHealthy: true
                    )
                }
                .padding(17)
                .background(.white.opacity(0.045))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.07), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))

                VStack(alignment: .leading, spacing: 8) {
                    Text("AI SECURITY LAYER")
                        .font(.caption.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(.secondary)

                    Text("Core Sentinel is the security intelligence layer for Shayan Core. The current version evaluates app-level health signals; external attack detection, anomaly analysis and automated response can be added as the security backend evolves.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(17)
                .background(.white.opacity(0.035))
                .clipShape(RoundedRectangle(cornerRadius: 18))

                Text("Last security signal check: \(dashboardStatus.lastCheckedText)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(20)
        }
        .background(Color(red: 0.025, green: 0.035, blue: 0.07))
        .navigationTitle("Core Sentinel")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await dashboardStatus.check()
        }
        .refreshable {
            await dashboardStatus.check()
        }
    }
}

private struct SentinelSignalRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let isHealthy: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(isHealthy ? .green : .orange)
                .frame(width: 40, height: 40)
                .background((isHealthy ? Color.green : Color.orange).opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 11))

            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: isHealthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(isHealthy ? .green : .orange)
        }
    }
}
