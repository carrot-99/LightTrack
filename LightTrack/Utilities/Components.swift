//  Components.swift
//  アプリ共通の UI 部品

import SwiftUI

// MARK: - 数値入力フィールド

/// 単位ラベル付きの数値入力欄（Form 内で使用）
struct NumberField: View {
    let title: String
    @Binding var text: String
    var unit: String
    var placeholder: String = ""
    var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                TextField(placeholder, text: $text)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120)
                    .accessibilityLabel(title)
                Text(unit)
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 24, alignment: .leading)
            }
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

// MARK: - 指標カード

struct MetricCard: View {
    let title: String
    let value: String
    var unit: String = ""
    var caption: String?
    var captionColor: Color = .secondary
    var systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(.title, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            // キャプションが無くても行を確保し、カードの高さを揃える
            Text(caption ?? " ")
                .font(.caption)
                .foregroundStyle(captionColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - ボタン

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor.opacity(isEnabled ? 1 : 0.4), in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - 変化量の表示

enum ChangeFormatter {
    /// 例: "+0.4 kg" / "-1.2 kg" / "±0.0 kg"
    static func signed(_ value: Double, unit: String = "kg") -> String {
        let rounded = (value * 10).rounded() / 10
        if rounded == 0 { return "±0.0 \(unit)" } // -0.0 も含む
        let sign = rounded > 0 ? "+" : ""
        return "\(sign)\(NumberInput.format(rounded)) \(unit)"
    }
}

// MARK: - 広告バナー

extension View {
    /// 画面下部（タブバーの上）に広告バナーを表示する
    func adBanner() -> some View {
        modifier(AdBannerModifier())
    }
}

/// キーボード表示中は入力欄を隠さないようバナーを非表示にする
private struct AdBannerModifier: ViewModifier {
    @State private var isKeyboardVisible = false

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isKeyboardVisible {
                    AdMobBannerView()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(.bar)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                isKeyboardVisible = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                isKeyboardVisible = false
            }
    }
}
