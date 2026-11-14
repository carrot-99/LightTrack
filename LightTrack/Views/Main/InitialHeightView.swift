//  InitialHeightView.swift

import SwiftUI

struct InitialHeightView: View {
    var onHeightSet: (Double) -> Void

    @State private var heightText = ""
    @FocusState private var isFocused: Bool

    private var height: Double? {
        NumberInput.parse(heightText).flatMap { ValidationRange.height.contains($0) ? $0 : nil }
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "figure.stand")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)

            VStack(spacing: 8) {
                Text("身長を入力してください")
                    .font(.title2.bold())
                Text("BMI の計算にのみ使用します。\nあとから設定画面で変更できます。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(alignment: .firstTextBaseline) {
                TextField("170.0", text: $heightText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                    .frame(maxWidth: 180)
                Text("cm")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))

            if !heightText.isEmpty && height == nil {
                Text("\(Int(ValidationRange.height.lowerBound))〜\(Int(ValidationRange.height.upperBound)) cm の範囲で入力してください")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer()

            Button("はじめる") {
                if let height { onHeightSet(height) }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(height == nil)
        }
        .padding(24)
        .onAppear { isFocused = true }
    }
}

#Preview {
    InitialHeightView { _ in }
}
