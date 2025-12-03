// Features/Home/HomeView.swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var trainingViewModel: TrainingViewModel
    
    @State private var userWeightData: [WeightData] = [
        WeightData(date: Date().addingTimeInterval(-6*24*3600), weight: 75.0),
        WeightData(date: Date().addingTimeInterval(-4*24*3600), weight: 74.5),
        WeightData(date: Date().addingTimeInterval(-2*24*3600), weight: 74.0),
        WeightData(date: Date(), weight: 73.5)
    ]
    
    var nextWorkout: Training? {
        let futureTrainings = trainingViewModel.trainings.filter { $0.date > Date() }
        return futureTrainings.sorted { $0.date < $1.date }.first
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Greeting
                greetingView
                
                // Next workout reminder
                NextWorkoutCard(
                    nextWorkout: nextWorkout,
                    onTap: {
                        // Навигация к созданию тренировки
                    }
                )
                
                // Weight progress chart
                WeightProgressChart(weightData: userWeightData)
                
                // User balance
                BalanceCard()
            }
            .padding(.vertical, 10)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Главная")
        .onAppear {
            trainingViewModel.loadTrainings()
        }
    }
    
    private var greetingView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(getGreeting())
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Работайте над своими целями")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private func getGreeting() -> String {
        let greeting = Helpers.getGreeting()
        
        if let user = authService.currentUser {
            return "\(greeting), \(user.displayName)!"
        } else {
            return "\(greeting)!"
        }
    }
}
