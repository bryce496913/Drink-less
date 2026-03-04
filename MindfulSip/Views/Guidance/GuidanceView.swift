import SwiftUI

struct GuidanceView: View {
    @EnvironmentObject var container: AppContainer
    @State private var feeling = ""

    private var guidanceMessage: String {
        let today = container.log(for: .now).totalDrinks
        if today == 0 {
            return "You’re doing great today. Keep your streak going with one small action, like having water before your next decision point."
        }
        if today <= 2 {
            return "You’re still within a recoverable moment. Pause for 90 seconds, breathe, and choose your next drink intentionally."
        }
        return "Today has been challenging, and that’s okay. Focus on reducing from this moment forward—switch to water now and aim for a calmer evening routine."
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("AI Guidance")
                        .font(AppTheme.font(.title2, weight: .bold))
                        .foregroundStyle(AppTheme.text)

                    Text("When things feel difficult, use this space to reset and get a practical next step.")
                        .font(AppTheme.font(.body))
                        .foregroundStyle(AppTheme.text.opacity(0.9))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("How are you feeling?")
                            .font(AppTheme.font(.headline, weight: .semibold))
                        TextField("e.g. stressed, social pressure, craving", text: $feeling)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Suggested guidance")
                            .font(AppTheme.font(.headline, weight: .semibold))
                        Text(feeling.isEmpty ? guidanceMessage : "You said: \(feeling). Try this: \(guidanceMessage)")
                            .font(AppTheme.font(.body))
                            .foregroundStyle(AppTheme.text.opacity(0.95))
                    }
                    .padding(14)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quick resets")
                            .font(AppTheme.font(.headline, weight: .semibold))
                        Text("• Drink a full glass of water")
                        Text("• Wait 10 minutes before deciding")
                        Text("• Message a friend for support")
                    }
                    .font(AppTheme.font(.body))
                    .foregroundStyle(AppTheme.text)
                    .padding(14)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    GuidanceView().environmentObject(AppContainer())
}
