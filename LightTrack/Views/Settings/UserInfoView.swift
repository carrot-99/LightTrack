//  UserInfoView.swift

import SwiftUI

struct UserInfoView: View {
    @EnvironmentObject private var viewModel: HealthDataViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var heightText = ""
    @State private var goalText = ""

    private var height: Double? {
        NumberInput.parse(heightText).flatMap { ValidationRange.height.contains($0) ? $0 : nil }
    }

    /// 未入力 → nil（目標なし）
    private var goal: Result<Double?, RecordInput.InputError> {
        if goalText.trimmingCharacters(in: .whitespaces).isEmpty { return .success(nil) }
        guard let value = NumberInput.parse(goalText), ValidationRange.weight.contains(value) else {
            return .failure(.invalid)
        }
        return .success(value)
    }

    private var isValid: Bool {
        guard height != nil, case .success = goal else { return false }
        return true
    }

    var body: some View {
        Form {
            Section {
                NumberField(
                    title: "身長",
                    text: $heightText,
                    unit: "cm",
                    errorMessage: !heightText.isEmpty && height == nil ? "50〜250 cm の範囲で入力してください" : nil
                )
            } footer: {
                if let height {
                    Text("標準体重（BMI 22）: \(NumberInput.format(BMI.idealWeight(heightCm: height))) kg")
                }
            }

            Section {
                NumberField(
                    title: "目標体重（任意）",
                    text: $goalText,
                    unit: "kg",
                    errorMessage: { if case .failure = goal { return "正しい体重を入力してください" } else { return nil } }()
                )
            } footer: {
                Text("設定すると、ホーム画面とグラフに目標までの差が表示されます。")
            }
        }
        .navigationTitle("身長・目標体重")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存", action: save)
                    .disabled(!isValid)
            }
        }
        .onAppear {
            heightText = NumberInput.format(viewModel.userHeight)
            goalText = viewModel.goalWeight.map { NumberInput.format($0) } ?? ""
        }
    }

    private func save() {
        guard let height, case .success(let goalValue) = goal else { return }
        viewModel.updateHeight(height)
        viewModel.goalWeight = goalValue
        dismiss()
    }
}

#Preview {
    NavigationStack {
        UserInfoView()
            .environmentObject(HealthDataViewModel.preview)
    }
}
