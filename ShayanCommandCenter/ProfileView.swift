import SwiftUI

struct ProfileView: View {
    @AppStorage("profileName") private var name = "Shayan"
    @AppStorage("profileTitle") private var title = "SAP ABAP Developer"
    @AppStorage("profileSummary") private var summary = "SAP professional focused on ABAP, S/4HANA, integrations and modern SAP cloud technologies."
    @AppStorage("profileExperience") private var experience = "3+ years"
    @AppStorage("profileFocus") private var focus = "ABAP • S/4HANA • OData • CPI • BTP"

    @State private var editing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                profileHeader

                VStack(alignment: .leading, spacing: 14) {
                    Text("ABOUT")
                        .font(.caption.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(.blue)

                    Text(summary)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .coreProfileCard()

                HStack(spacing: 12) {
                    profileMetric(title: "Experience", value: experience, icon: "briefcase.fill")
                    profileMetric(title: "Focus", value: focus, icon: "square.stack.3d.up.fill")
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("PROFESSIONAL PROFILE")
                        .font(.caption.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(.blue)

                    profileRow("SAP ABAP", icon: "chevron.left.forwardslash.chevron.right")
                    profileRow("S/4HANA & CDS", icon: "shippingbox.fill")
                    profileRow("OData & Integrations", icon: "arrow.triangle.2.circlepath")
                    profileRow("BTP & Cloud", icon: "cloud.fill")
                }
                .coreProfileCard()

                Button {
                    editing = true
                } label: {
                    Label("Edit Profile", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(20)
        }
        .background(Color(red: 0.025, green: 0.035, blue: 0.07))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $editing) {
            editProfile
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 92, height: 92)

                Text(initials)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text(name)
                .font(.largeTitle.bold())

            Text(title)
                .font(.headline)
                .foregroundStyle(.blue)

            Text("Your professional identity inside Shayan Core")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var initials: String {
        let parts = name.split(separator: " ")
        return String(parts.prefix(2).compactMap { $0.first })
    }

    private func profileMetric(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .coreProfileCard()
    }

    private func profileRow(_ text: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 30)
            Text(text)
                .font(.subheadline.weight(.semibold))
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }

    private var editProfile: some View {
        NavigationStack {
            Form {
                Section("Identity") {
                    TextField("Name", text: $name)
                    TextField("Professional title", text: $title)
                    TextField("Experience", text: $experience)
                }

                Section("About") {
                    TextEditor(text: $summary)
                        .frame(minHeight: 120)
                }

                Section("Technical focus") {
                    TextField("Focus areas", text: $focus)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { editing = false }
                }
            }
        }
        .presentationDetents([.large])
    }
}

private extension View {
    func coreProfileCard() -> some View {
        self
            .padding(18)
            .background(.white.opacity(0.055))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
