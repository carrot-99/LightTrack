//  GraphView.swift

import SwiftUI
import SwiftUICharts

struct GraphView: View {
    @EnvironmentObject var viewModel: HealthDataViewModel
    @State private var selectedPeriod: Period = .week
    @State private var isLoading = false

    var body: some View {
        VStack {
            Picker("Period", selection: $selectedPeriod) {
                Text("週").tag(Period.week)
                Text("月").tag(Period.month)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color(red: 44 / 255, green: 44 / 255, blue: 46 / 255))
            .onChange(of: selectedPeriod) { newValue in
                viewModel.updateDataPoints(forPeriod: newValue)
            }
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else if !viewModel.weights.isEmpty {
                let weightDataPoints = viewModel.generateDataPoints(forPeriod: selectedPeriod)
                let weightData = LineDataSet(dataPoints: weightDataPoints, legendTitle: "体重(kg)")
                
                let minWeight = viewModel.weights.min() ?? 0
                let maxWeight = viewModel.weights.max() ?? 0
                let padding = (maxWeight - minWeight) * 0.2

                let chartStyle = LineChartStyle(
                    xAxisLabelPosition: .bottom,
                    xAxisLabelColour: Color.white,
                    xAxisLabelsFrom: .dataPoint(rotation: .degrees(-90)),
                    yAxisLabelPosition: .leading,
                    yAxisLabelColour: Color.white,
                    yAxisNumberOfLabels: 5,
                    baseline: .zero,
                    topLine: .maximum(of: (maxWeight+padding))
                )

                let weightChartData = LineChartData(
                    dataSets: weightData,
                    metadata: ChartMetadata(title: "体重の推移", subtitle: "過去30日間"),
                    chartStyle: chartStyle
                )

                VStack {
                    LineChart(chartData: weightChartData)
                        .legends(chartData: weightChartData)
                        .pointMarkers(chartData: weightChartData)
                        .xAxisGrid(chartData: weightChartData)
                        .xAxisLabels(chartData: weightChartData)
                        .yAxisGrid(chartData: weightChartData)
                        .yAxisLabels(chartData: weightChartData)
                }
                .padding()
            } else {
                Text("データがありません")
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .background(Color(red: 44 / 255, green: 44 / 255, blue: 46 / 255))
//        .navigationTitle("グラフ")
        .foregroundColor(.white)
    }
    
    func refreshData() {
        isLoading = true
        viewModel.fetchLatestHealthData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false 
        }
    }
}
