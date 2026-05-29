import SwiftUI

struct WeatherCard: View {
    let weather: WeatherInfo

    var body: some View {
        AppCard {
            HStack(spacing: 16) {
                temperatureView
                Divider()
                    .frame(height: 60)
                infoView
                Spacer(minLength: 0)
                jacketView
            }
            .padding(16)
        }
    }

    private var temperatureView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(weather.stationName)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            HStack(alignment: .top, spacing: 0) {
                Text("\(Int(round(weather.temperature)))")
                    .font(.system(size: 36, weight: .bold))
                Text("\u{00B0}")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var infoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .font(.caption2)
                    .foregroundStyle(Color(.systemBlue))
                Text("\(String(format: "%.1f", weather.precipitation)) mm")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 4) {
                Image(systemName: "wind")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(Int(round(weather.windspeed))) km/h")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var jacketView: some View {
        VStack(spacing: 4) {
            Image(systemName: jacketIcon)
                .font(.title3)
                .foregroundStyle(jacketColor)
            Text(weather.jacketRecommendation.rawValue)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 60)
    }

    private var jacketIcon: String {
        switch weather.jacketRecommendation {
        case .none: return "tshirt.fill"
        case .light: return "tshirt.fill"
        case .warm: return "snowflake"
        case .rain: return "umbrella.fill"
        case .wind: return "wind"
        }
    }

    private var jacketColor: Color {
        switch weather.jacketRecommendation {
        case .none: return .green
        case .light: return .orange
        case .warm: return .blue
        case .rain: return Color(.systemCyan)
        case .wind: return .secondary
        }
    }
}

#Preview {
    WeatherCard(weather: sampleWeather)
        .padding()
}
