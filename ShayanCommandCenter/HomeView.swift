import UIKit
import SwiftUI

struct HomeView: View {
    @StateObject private var status = DashboardStatus()
    private let dashboardURL = URL(string: "https://shayan263.github.io/Shayan_Profile/admin.html")!

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.025, green: 0.035, blue: 0.07).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("SHAYAN COMMAND CENTER")
                                .font(.caption).fontWeight(.bold).tracking(1.5)
                                .foregroundStyle(.blue)
                            Text("Good evening, Shayan 👋")
                                .font(.largeTitle.bold())
                            Text("Your personal command center")
                                .foregroundStyle(.secondary)
                        }

                        DashboardCard(status: status) {
                            UIApplication.shared.open(dashboardURL)
                        }

                        Text("More capabilities coming soon")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
            .task { await status.check() }
            .refreshable { await status.check() }
        }
    }
}

struct DashboardCard: View {
    @ObservedObject var status: DashboardStatus
    let onDetails: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .font(.title2).foregroundStyle(.blue)
                    .frame(width: 44, height: 44)
                    .background(.blue.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 13))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Portfolio Dashboard").font(.headline)
                    Text("Private analytics").font(.caption).foregroundStyle(.secondary)
                }

                Spacer()
                StatusPill(isOnline: status.isOnline)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(status.isOnline ? "Dashboard is live" : "Dashboard unavailable")
                    .font(.title3.bold())

                HStack(spacing: 8) {
                    Circle()
                        .fill(status.isOnline ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(status.isOnline ? "Online" : "Offline")
                        .font(.subheadline.weight(.semibold))
                    Text("•").foregroundStyle(.secondary)
                    Text(status.lastCheckedText)
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            Button(action: onDetails) {
                HStack {
                    Text("View Details").fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .padding(.horizontal, 16).padding(.vertical, 13)
                .background(LinearGradient(colors: [.blue, .purple],
                                           startPoint: .leading, endPoint: .trailing))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 13))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(.white.opacity(0.055))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.09), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct StatusPill: View {
    let isOnline: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(isOnline ? Color.green : Color.red).frame(width: 7, height: 7)
            Text(isOnline ? "LIVE" : "OFFLINE")
                .font(.caption2.bold()).tracking(0.8)
        }
        .padding(.horizontal, 10).padding(.vertical, 7)
        .background((isOnline ? Color.green : Color.red).opacity(0.10))
        .foregroundStyle(isOnline ? .green : .red)
        .clipShape(Capsule())
    }
}
