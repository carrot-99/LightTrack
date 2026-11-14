//  HomeView.swift

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: HealthDataViewModel
    @State private var input = RecordInput()
    @State private var showSavedMessage = false
    @State private var showSaveError = false
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    summaryCards
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                Section("今日の記録") {
                    RecordFormFields(input: $input)
                        .focused($focused)
                }

                Section {
                    Button("記録する", action: save)
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(!input.isValid)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("LightTrack")
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完了") { focused = false }
                }
            }
            .overlay(alignment: .top) {
                if showSavedMessage {
                    Label("記録しました", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.thinMaterial, in: Capsule())
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 8)
                }
            }
            .alert("保存に失敗しました", isPresented: $showSaveError) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    // MARK: - サマリー

    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            MetricCard(
                title: "体重",
                value: viewModel.latest.map { NumberInput.format($0.weight) } ?? "--",
                unit: "kg",
                caption: weightCaption,
                captionColor: weightCaptionColor,
                systemImage: "scalemass"
            )
            MetricCard(
                title: "BMI",
                value: viewModel.latestBMI.map { NumberInput.format($0) } ?? "--",
                caption: viewModel.latestBMI.map { BMI.category(for: $0) },
                systemImage: "figure.stand"
            )
            MetricCard(
                title: "体脂肪率",
                value: viewModel.latestBodyFat.map { NumberInput.format($0) } ?? "--",
                unit: "%",
                systemImage: "drop"
            )
            MetricCard(
                title: "目標まで",
                value: viewModel.remainingToGoal.map { NumberInput.format(abs($0)) } ?? "--",
                unit: viewModel.remainingToGoal == nil ? "" : "kg",
                caption: goalCaption,
                systemImage: "flag.checkered"
            )
        }
    }

    private var weightCaption: String {
        guard let change = viewModel.weightChangeFromPrevious else {
            return viewModel.latest == nil ? "まだ記録がありません" : "前回の記録なし"
        }
        return "前回比 \(ChangeFormatter.signed(change))"
    }

    private var weightCaptionColor: Color {
        guard let change = viewModel.weightChangeFromPrevious else { return .secondary }
        if abs(change) < 0.05 { return .secondary }
        return change < 0 ? .green : .orange
    }

    private var goalCaption: String {
        guard let goal = viewModel.goalWeight else { return "設定から目標を登録" }
        if let remaining = viewModel.remainingToGoal, abs(remaining) < 0.05 { return "目標達成！" }
        return "目標 \(NumberInput.format(goal)) kg"
    }

    // MARK: - 保存

    private func save() {
        guard let weight = input.weight, case .success(let bodyFat) = input.bodyFat else { return }
        focused = false
        guard viewModel.addRecord(date: input.date, weight: weight, bodyFatPercentage: bodyFat) else {
            showSaveError = true
            return
        }
        input = RecordInput()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation { showSavedMessage = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showSavedMessage = false }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(HealthDataViewModel.preview)
}
