import SwiftUI

struct OnboardingSheet: View {
    var onDismiss: () -> Void

    var body: some View {
        TabView {
            OnboardingPage(
                icon: "wifi",
                title: "Mit WIFIonICE verbinden",
                description: "ICE Info zeigt dir Echtzeit-Informationen zu deiner ICE-Reise an, sobald du mit dem Bord-WLAN \"WIFIonICE\" verbunden bist."
            )
            OnboardingPage(
                icon: "tram.fill",
                title: "Alle Informationen auf einen Blick",
                description: "Verfolge Geschwindigkeit, n\u{00E4}chste Halte, Versp\u{00E4}tungen und mehr \u{00FC}ber mehrere Bildschirme."
            )
            OnboardingPage(
                icon: "map.fill",
                title: "Karte und Points of Interest",
                description: "Sieh deine Position auf der Karte und entdecke Sehensw\u{00FC}rdigkeiten entlang der Strecke."
            )
            OnboardingPage(
                icon: "arrow.triangle.branch",
                title: "Anschl\u{00FC}sse und Abfahrten",
                description: "Erhalte Informationen zu Anschlussz\u{00FC}gen und weiteren Abfahrten an deinem Zielbahnhof."
            )
            OnboardingPage(
                icon: "slider.horizontal.3",
                title: "Demo-Modus",
                description: "Kein ICE in der N\u{00E4}he? Nutze den Demo-Modus, um die App mit Beispieldaten zu erkunden."
            ) {
                onDismiss()
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .ignoresSafeArea()
    }
}

private struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(Color(red: 0.925, green: 0, blue: 0.086))
            Text(title)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            if let action {
                Button("Los geht\u{2019}s!") {
                    action()
                }
                .font(.body.weight(.semibold))
                .frame(maxWidth: 280)
                .padding(.vertical, 12)
                .background(Color(red: 0.925, green: 0, blue: 0.086))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 60)
            }
        }
    }
}
