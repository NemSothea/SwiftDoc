// Journal/Views/WeatherPickerView.swift
import SwiftUI

/// Four-button row for picking a weather tag when creating or editing an entry.
struct WeatherPickerView: View {
    @Binding var selection: Weather

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Weather.allCases) { weather in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selection = weather
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: weather.symbolName)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(selection == weather ? .white : weather.tint)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle().fill(selection == weather
                                              ? weather.tint
                                              : Color(.systemGray6))
                            )
                        Text(weather.label)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 4)
    }
}
