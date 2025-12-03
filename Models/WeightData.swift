// Models/WeightData.swift
import Foundation

struct WeightData: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let weight: Double
    
    init(date: Date, weight: Double) {
        self.date = date
        self.weight = weight
    }
}
