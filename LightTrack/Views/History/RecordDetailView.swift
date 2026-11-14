//  RecordDetailView.swift

import SwiftUI

// MARK: - 入力状態とバリデーション（ホーム画面・編集画面で共通）

struct RecordInput {
    var date = Date()
    var weightText = ""
    var bodyFatText = ""

    init() {}

    init(record: HealthData) {
        date = record.date
        // 68.30 → 68.3、68.25 → 68.25 のように不要な 0 を付けない
        weightText = record.weight.formatted(.number.precision(.fractionLength(1...2)).grouping(.never))
        bodyFatText = record.bodyFatPercentage.map { NumberInput.format($0) } ?? ""
    }

    var weight: Double? {
        NumberInput.parse(weightText).flatMap { ValidationRange.weight.contains($0) ? $0 : nil }
    }

    /// 未入力は nil（任意項目）、不正値は .invalid
    var bodyFat: Result<Double?, InputError> {
        guard !bodyFatText.trimmingCharacters(in: .whitespaces).isEmpty else { return .success(nil) }
        guard let value = NumberInput.parse(bodyFatText), ValidationRange.bodyFat.contains(value) else {
            return .failure(.invalid)
        }
        return .success(value)
    }

    var weightError: String? {
        guard !weightText.isEmpty, weight == nil else { return nil }
        return "\(Int(ValidationRange.weight.lowerBound))〜\(Int(ValidationRange.weight.upperBound)) kg の範囲で入力してください"
    }

    var bodyFatError: String? {
        guard case .failure = bodyFat else { return nil }
        return "\(Int(ValidationRange.bodyFat.lowerBound))〜\(Int(ValidationRange.bodyFat.upperBound)) % の範囲で入力してください"
    }

    var isValid: Bool {
        guard weight != nil, case .success = bodyFat else { return false }
        return date <= Date().addingTimeInterval(60)
    }

    enum InputError: Error { case invalid }
}

struct RecordFormFields: View {
    @Binding var input: RecordInput

    var body: some View {
        DatePicker("測定日時", selection: $input.date, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
        NumberField(title: "体重", text: $input.weightText, unit: "kg", placeholder: "65.0", errorMessage: input.weightError)
        NumberField(title: "体脂肪率（任意）", text: $input.bodyFatText, unit: "%", placeholder: "20.0", errorMessage: input.bodyFatError)
    }
}

// MARK: - 編集画面

struct RecordDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: HealthDataViewModel

    let record: HealthData
    @State private var input: RecordInput
    @State private var isConfirmingDelete = false

    init(record: HealthData) {
        self.record = record
        _input = State(initialValue: RecordInput(record: record))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    RecordFormFields(input: $input)
                }
                if let weight = input.weight, let bmi = BMI.value(weightKg: weight, heightCm: viewModel.userHeight) {
                    Section {
                        LabeledContent("BMI", value: "\(NumberInput.format(bmi))（\(BMI.category(for: bmi))）")
                    }
                }
                Section {
                    Button("この記録を削除", role: .destructive) {
                        isConfirmingDelete = true
                    }
                }
            }
            .navigationTitle("記録を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存", action: save)
                        .disabled(!input.isValid)
                }
            }
            .confirmationDialog("この記録を削除しますか？", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
                Button("削除", role: .destructive) {
                    viewModel.deleteRecords([record])
                    dismiss()
                }
            }
        }
    }

    private func save() {
        guard let weight = input.weight, case .success(let bodyFat) = input.bodyFat else { return }
        viewModel.updateRecord(record, date: input.date, weight: weight, bodyFatPercentage: bodyFat)
        dismiss()
    }
}

#Preview {
    RecordDetailView(record: HealthData(date: Date(), weight: 65.2, bodyFatPercentage: 20.1))
        .environmentObject(HealthDataViewModel.preview)
}
