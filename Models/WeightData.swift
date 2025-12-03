// Models/WeightData.swift
import Foundation

struct WeightData: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let weight: Double
    
    init(date: Date, weight: Double) {
        self.date = date
        self.weight = weight
    }
}
