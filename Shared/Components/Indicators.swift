// Shared/Components/Indicators.swift
import SwiftUI

struct LoadingIndicator: View {
    var size: CGFloat = 20
    var color: Color = .blue
    
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: color))
            .scaleEffect(1.2)
    }
}

struct ProgressBar: View {
    let progress: Double
    let height: CGFloat = 8
    var backgroundColor: Color = .gray.opacity(0.3)
    var progressColor: Color = .blue
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(backgroundColor)
                    .cornerRadius(height / 2)
                
                Rectangle()
                    .foregroundColor(progressColor)
                    .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width))
                    .cornerRadius(height / 2)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }
        }
        .padding(.vertical, 40)
    }
}

struct Badge: View {
    let count: Int
    var backgroundColor: Color = .red
    var foregroundColor: Color = .white
    
    var body: some View {
        if count > 0 {
            Text("\(count)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(foregroundColor)
                .frame(minWidth: 16, minHeight: 16)
                .background(backgroundColor)
                .cornerRadius(8)
        }
    }
}

// MARK: - Previews
struct Indicators_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            LoadingIndicator()
            
            ProgressBar(progress: 0.7)
                .frame(width: 200)
            
            EmptyStateView(
                icon: "calendar",
                title: "Нет тренировок",
                message: "Запланируйте свою первую тренировку",
                actionTitle: "Создать тренировку",
                action: {}
            )
            
            HStack(spacing: 10) {
                Badge(count: 5)
                Badge(count: 0)
                Badge(count: 99)
            }
        }
        .padding()
    }
}
