import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService()
    
    var body: some View {
        Group {
            switch authService.authState {
            case .authenticated, .guest:
                MainTabView()
                    .environmentObject(authService)
                
            case .unauthenticated:
                AuthenticationView()
                    .environmentObject(authService)
                
            case .loading:
                LoadingView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authService.isAuthenticated)
    }
}

// MARK: - Enhanced Loading View
struct LoadingView: View {
    @State private var isRotating = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Animated icon
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
                        .onAppear {
                            withAnimation(
                                Animation.linear(duration: 1)
                                    .repeatForever(autoreverses: false)
                            ) {
                                isRotating = true
                            }
                        }
                    
                    Image(systemName: "dumbbell.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 8) {
                    Text("PumpApp")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Загрузка...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Welcome View (может использоваться для онбординга)
struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.blue)
                
                Text("Добро пожаловать в PumpApp")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Твой персональный помощник в мире фитнеса")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Text("Начни свой фитнес-путь")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 20) {
                    FeatureView(
                        icon: "calendar",
                        title: "Планирование",
                        description: "Расписание тренировок"
                    )
                    
                    FeatureView(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Прогресс",
                        description: "Отслеживание результатов"
                    )
                    
                    FeatureView(
                        icon: "message",
                        title: "Поддержка",
                        description: "Чат с тренером"
                    )
                }
            }
            .padding(.bottom, 50)
        }
        .padding()
    }
}

struct FeatureView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 50, height: 50)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
