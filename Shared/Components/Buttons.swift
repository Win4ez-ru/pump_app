// Shared/Components/Buttons.swift
import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var backgroundColor: Color = .blue
    var foregroundColor: Color = .white
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .opacity(isLoading ? 0 : 1)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(foregroundColor)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
                    .background(backgroundColor)
                    .cornerRadius(12)
                    .opacity(isDisabled ? 0.6 : 1)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                }
            }
        }
        .disabled(isLoading || isDisabled)
        .scaleEffect(isLoading ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var foregroundColor: Color = .blue
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(foregroundColor)
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(foregroundColor, lineWidth: 2)
                )
                .opacity(isDisabled ? 0.6 : 1)
        }
        .disabled(isDisabled)
    }
}

struct IconButton: View {
    let icon: String
    let action: () -> Void
    var backgroundColor: Color = .blue
    var foregroundColor: Color = .white
    var size: CGFloat = 44
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size)
                .background(backgroundColor)
                .cornerRadius(10)
        }
    }
}

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    var backgroundColor: Color = .blue
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(backgroundColor)
                .cornerRadius(28)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Previews
struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PrimaryButton(title: "Войти", action: {})
            
            PrimaryButton(title: "Загрузка...", action: {}, isLoading: true)
            
            SecondaryButton(title: "Зарегистрироваться", action: {})
            
            HStack {
                IconButton(icon: "plus", action: {})
                IconButton(icon: "trash", action: {}, backgroundColor: .red)
                IconButton(icon: "pencil", action: {}, backgroundColor: .green)
            }
            
            FloatingActionButton(icon: "plus", action: {})
        }
        .padding()
    }
}
