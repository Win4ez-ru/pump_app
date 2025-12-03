// Models/Training.swift
import Foundation

enum TrainingType: String, CaseIterable, Codable {
    case strength = "Силовая"
    case cardio = "Кардио"
    case yoga = "Йога"
    case stretching = "Растяжка"
}

struct Exercise: Identifiable, Codable {
    let id: String
    var name: String
    var sets: Int?
    var reps: Int?
    var weight: Double?
    var duration: Int?
    var intensity: Int?
    
    init(id: String = UUID().uuidString, name: String, sets: Int? = nil, reps: Int? = nil, weight: Double? = nil, duration: Int? = nil, intensity: Int? = nil) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.intensity = intensity
    }
}

struct Training: Identifiable, Codable {
    let id: String
    let title: String
    let date: Date
    let type: TrainingType
    var exercises: [Exercise]
    
    init(id: String = UUID().uuidString,
         title: String,
         date: Date,
         type: TrainingType,
         exercises: [Exercise] = []) {
        self.id = id
        self.title = title
        self.date = date
        self.type = type
        self.exercises = exercises
    }
}
