//  GraphView.swift

import SwiftUI
import Charts

struct GraphView: View {
    @EnvironmentObject private var viewModel: HealthDataViewModel
    @AppStorage("graph.period") private var period: ChartPeriod = .month
    @AppStorage("graph.metric") private var metric: ChartMetric = .weight
    @State private var selectedPoint: ChartPoint?

    private var points: [ChartPoint] {
        viewModel.chartPoints(metric: metric, period: period)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Picker("項目", selection: $metric) {
                        ForEach(ChartMetric.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    Picker("期間", selection: $period) {
                        ForEach(ChartPeriod.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    let points = points
                    if points.isEmpty {
                        EmptyStateView(
                            title: "データがありません",
                            systemImage: "chart.xyaxis.line",
                            message: "この期間の\(metric.rawValue)の記録がありません"
                        )
                        .frame(height: 300)
                    } else {
                        header(points: points)
                        chart(points: points)
                            .frame(height: 300)
                        StatsView(points: points, unit: metric.unit)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("グラフ")
            .onChange(of: metric) { _ in selectedPoint = nil }
            .onChange(of: period) { _ in selectedPoint = nil }
        }
    }

    // MARK: - ヘッダー（選択中 or 最新値）

    private func header(points: [ChartPoint]) -> some View {
        let shown = selectedPoint ?? points.last
        return VStack(alignment: .leading, spacing: 2) {
            Text(shown.map { $0.date.formatted(date: .abbreviated, time: .omitted) } ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(shown.map { NumberInput.format($0.value) } ?? "--")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .monospacedDigit()
                Text(metric.unit)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - グラフ本体

    private func chart(points: [ChartPoint]) -> some View {
        let domain = yDomain(for: points)
        return Chart {
            ForEach(points) { point in
                LineMark(x: .value("日付", point.date, unit: .day), y: .value(metric.rawValue, point.value))
                    .interpolationMethod(.monotone)
                    .foregroundStyle(Color.accentColor)
                AreaMark(
                    x: .value("日付", point.date, unit: .day),
                    yStart: .value("下限", domain.lowerBound),
                    yEnd: .value(metric.rawValue, point.value)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(LinearGradient(colors: [Color.accentColor.opacity(0.25), .clear], startPoint: .top, endPoint: .bottom))
                if points.count <= 31 {
                    PointMark(x: .value("日付", point.date, unit: .day), y: .value(metric.rawValue, point.value))
                        .symbolSize(24)
                        .foregroundStyle(Color.accentColor)
                }
            }

            if metric == .weight, let goal = viewModel.goalWeight {
                RuleMark(y: .value("目標", goal))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(.green)
                    .annotation(position: .top, alignment: .leading) {
                        Text("目標 \(NumberInput.format(goal))kg").font(.caption2).foregroundStyle(.green)
                    }
            }

            if let selectedPoint {
                RuleMark(x: .value("選択", selectedPoint.date, unit: .day))
                    .foregroundStyle(.secondary.opacity(0.5))
                PointMark(x: .value("日付", selectedPoint.date, unit: .day), y: .value(metric.rawValue, selectedPoint.value))
                    .symbolSize(80)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .chartYScale(domain: domain)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                guard let date: Date = proxy.value(atX: x) else { return }
                                selectedPoint = points.min { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }
                            }
                            .onEnded { _ in selectedPoint = nil }
                    )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    /// 値の範囲に合わせて Y 軸を調整（以前は 0 起点で変化が見えにくかった）
    private func yDomain(for points: [ChartPoint]) -> ClosedRange<Double> {
        var values = points.map(\.value)
        if metric == .weight, let goal = viewModel.goalWeight { values.append(goal) }
        guard let minValue = values.min(), let maxValue = values.max() else { return 0...1 }
        let padding = max((maxValue - minValue) * 0.2, 1)
        return (minValue - padding).rounded(.down)...(maxValue + padding).rounded(.up)
    }
}

// MARK: - 統計

private struct StatsView: View {
    let points: [ChartPoint]
    let unit: String

    var body: some View {
        let values = points.map(\.value)
        let average = values.reduce(0, +) / Double(values.count)
        let change = (values.last ?? 0) - (values.first ?? 0)

        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            MetricCard(title: "平均", value: NumberInput.format(average), unit: unit, systemImage: "equal")
            MetricCard(title: "期間中の変化", value: ChangeFormatter.signed(change, unit: unit), systemImage: "arrow.up.arrow.down")
            MetricCard(title: "最小", value: NumberInput.format(values.min() ?? 0), unit: unit, systemImage: "arrow.down")
            MetricCard(title: "最大", value: NumberInput.format(values.max() ?? 0), unit: unit, systemImage: "arrow.up")
        }
    }
}

#Preview {
    GraphView()
        .environmentObject(HealthDataViewModel.preview)
}
