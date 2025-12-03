// Features/Home/Components/WeightProgressChart.swift
import SwiftUI
import Charts

struct WeightProgressChart: View {
    let weightData: [WeightData]
    var currentWeight: Double? {
        weightData.last?.weight
    }
    
    var weightChange: Double? {
        guard weightData.count >= 2,
              let first = weightData.first?.weight,
              let last = weightData.last?.weight else { return nil }
        return last - first
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Прогресс веса")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let current = currentWeight, let change = weightChange {
                        HStack(spacing: 6) {
                            Text("\(current, specifier: "%.1f") кг")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("\(change > 0 ? "+" : "")\(change, specifier: "%.1f") кг")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(change > 0 ? .red : .green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(change > 0 ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            if weightData.count >= 2 {
                Chart(weightData) { data in
                    LineMark(
                        x: .value("Дата", data.date, unit: .day),
                        y: .value("Вес", data.weight)
                    )
                    .foregroundStyle(.blue.gradient)
                    .symbol(Circle().strokeBorder(lineWidth: 2))
                    .symbolSize(40)
                    
                    PointMark(
                        x: .value("Дата", data.date, unit: .day),
                        y: .value("Вес", data.weight)
                    )
                    .foregroundStyle(.blue)
                    .annotation(position: .top) {
                        Text("\(data.weight, specifier: "%.1f")")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date.toString(format: "dd.MM"))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let weight = value.as(Double.self) {
                                Text("\(weight, specifier: "%.0f")")
                                    .font(.caption2)
                            }
                        }
                    }
                }
            } else {
                EmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Недостаточно данных",
                    message: "Добавьте больше измерений веса для построения графика"
                )
                .frame(height: 150)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}
