//  HistoryView.swift

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var viewModel: HealthDataViewModel
    @State private var editingRecord: HealthData?
    @State private var pendingDeletion: [HealthData] = []

    /// 月ごとにグループ化した記録（新しい順）
    private var sections: [(month: Date, records: [HealthData])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: viewModel.records) { record in
            calendar.date(from: calendar.dateComponents([.year, .month], from: record.date)) ?? record.date
        }
        return grouped.keys.sorted(by: >).map { ($0, grouped[$0] ?? []) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.records.isEmpty {
                    EmptyStateView(
                        title: "記録がありません",
                        systemImage: "list.bullet.rectangle",
                        message: "ホーム画面から体重を記録しましょう"
                    )
                } else {
                    list
                }
            }
            .navigationTitle("履歴")
            .toolbar {
                if !viewModel.records.isEmpty {
                    EditButton()
                }
            }
            .sheet(item: $editingRecord) { record in
                RecordDetailView(record: record)
            }
            .confirmationDialog(
                "\(pendingDeletion.count)件の記録を削除しますか？",
                isPresented: Binding(get: { !pendingDeletion.isEmpty }, set: { if !$0 { pendingDeletion = [] } }),
                titleVisibility: .visible
            ) {
                Button("削除", role: .destructive) {
                    viewModel.deleteRecords(pendingDeletion)
                    pendingDeletion = []
                }
            }
        }
    }

    private var list: some View {
        List {
            ForEach(sections, id: \.month) { section in
                Section(section.month.formatted(.dateTime.year().month(.wide))) {
                    ForEach(section.records) { record in
                        Button {
                            editingRecord = record
                        } label: {
                            RecordRow(record: record, previous: previousRecord(of: record))
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        pendingDeletion = offsets.map { section.records[$0] }
                    }
                }
            }
        }
    }

    private func previousRecord(of record: HealthData) -> HealthData? {
        guard let index = viewModel.records.firstIndex(of: record) else { return nil }
        let next = viewModel.records.index(after: index)
        return next < viewModel.records.endIndex ? viewModel.records[next] : nil
    }
}

private struct RecordRow: View {
    let record: HealthData
    let previous: HealthData?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.date.formatted(.dateTime.month().day().weekday(.abbreviated).hour().minute()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(NumberInput.format(record.weight))
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .monospacedDigit()
                    Text("kg").font(.caption).foregroundStyle(.secondary)
                    if let bodyFat = record.bodyFatPercentage {
                        Text("体脂肪 \(NumberInput.format(bodyFat))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 8)
                    }
                }
            }
            Spacer()
            if let previous {
                let change = record.weight - previous.weight
                Text(ChangeFormatter.signed(change))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(abs(change) < 0.05 ? Color.secondary : (change < 0 ? .green : .orange))
            }
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .accessibilityHint("タップして編集")
    }
}

/// iOS 16 でも使える ContentUnavailableView 相当
struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(title).font(.title3.bold())
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    HistoryView()
        .environmentObject(HealthDataViewModel.preview)
}
