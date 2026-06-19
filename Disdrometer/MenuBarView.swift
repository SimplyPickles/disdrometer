//
//
//  MenuBarView.swift
//  Disdrometer
//
//  SwiftUI view displayed in the menu‑bar dropdown. It presents a header,
//  a set of sliders that bind directly to the shared `RainController`
//  settings, and a quit button.
//
//  Created by Dylan Fraser on 6/17/26.
//

import SwiftUI

struct MenuBarView: View {
  @ObservedObject var controller: RainController
  @State private var showAbout = false

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Header with toggle
      HStack(alignment: .top, spacing: 12) {
        VStack(alignment: .leading, spacing: 4) {
          HStack {
            Image(systemName: "cloud.rain.fill")
              .font(.system(size: 12, weight: .semibold))
            Text("Disdrometer")
              .font(.system(size: 12, weight: .semibold, design: .default))
          }
          Text("Desktop rain")
            .font(.system(size: 10, design: .default))
            .foregroundStyle(.secondary)
        }
        Spacer()
        Toggle("", isOn: $controller.isRunning)
          .toggleStyle(.switch)
          .labelsHidden()
      }

      Divider()

      // Sliders
      VStack(alignment: .leading, spacing: 12) {
        SliderControl(
          label: "Intensity",
          value: Binding(
            get: { Double(controller.intensity) },
            set: { controller.intensity = Float($0) }
          ),
          range: 20...400,
          format: { String(format: "%.0f drops/s", $0) }
        )

        SliderControl(
          label: "Fall Speed",
          value: $controller.fallSpeed,
          range: 200...1600,
          format: { String(format: "%.0f pt/s", $0) }
        )

        SliderControl(
          label: "Wind Angle",
          value: $controller.angleDegrees,
          range: -30...30,
          format: { String(format: "%.0f°", $0) }
        )

        SliderControl(
          label: "Opacity",
          value: $controller.opacity,
          range: 0.1...1.0,
          format: { String(format: "%.0f%%", $0 * 100) }
        )

        SliderControl(
          label: "Lifetime",
          value: $controller.lifetime,
          range: 1...15,
          format: { String(format: "%.1fs", $0) }
        )

        // Drop Style Picker
        VStack(alignment: .leading, spacing: 6) {
          HStack {
            Text("Drop Style")
              .font(.system(size: 11, weight: .semibold, design: .default))
            Spacer()
            Text(controller.dropStyle.rawValue)
              .font(.system(size: 11, weight: .regular, design: .monospaced))
              .foregroundStyle(.secondary)
          }
          Picker("", selection: $controller.dropStyle) {
            ForEach(DropStyle.allCases, id: \.self) { style in
              Text(style.rawValue).tag(style)
            }
          }
          .pickerStyle(.menu)
          .frame(maxWidth: .infinity)
        }

        // Dimming Controls
        VStack(alignment: .leading, spacing: 6) {
          Toggle("Background Dimming", isOn: $controller.dimEnabled)
            .font(.system(size: 11, weight: .semibold, design: .default))

          if controller.dimEnabled {
            SliderControl(
              label: "Dim Opacity",
              value: $controller.dimOpacity,
              range: 0.0...0.8,
              format: { String(format: "%.0f%%", $0 * 100) }
            )
          }
        }
      }

      Divider()

      // About & Quit buttons
      VStack(spacing: 8) {
        Button(action: { NSApp.terminate(nil) }) {
          Text("Quit")
            .frame(maxWidth: .infinity)
        }
        .keyboardShortcut("q")
      }
    }
    .padding(12)
    .frame(width: 260)
  }
}

struct SliderControl: View {
  let label: String
  @Binding var value: Double
  let range: ClosedRange<Double>
  let format: (Double) -> String

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text(label)
          .font(.system(size: 11, weight: .semibold, design: .default))
        Spacer()
        Text(format(value))
          .font(.system(size: 11, weight: .regular, design: .monospaced))
          .foregroundStyle(.secondary)
          .frame(minWidth: 70, alignment: .trailing)
      }
      Slider(value: $value, in: range)
    }
  }
}

#Preview {
  MenuBarView(controller: RainController())
}
