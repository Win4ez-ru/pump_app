import SwiftUI

struct EmailField: View {
    let title: String
    @Binding var text: String
    var validationMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField("your@email.com", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textContentType(.emailAddress)
                .disableAutocorrection(true)
            
            if let message = validationMessage {
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

struct PasswordField: View {
    let title: String
    @Binding var text: String
    var validationMessage: String?
    var showConfirmation: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            SecureField(showConfirmation ? "Повторите пароль" : "Введите пароль", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(showConfirmation ? .newPassword : .password)
            
            if let message = validationMessage {
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

struct UsernameField: View {
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Имя пользователя")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField("Придумайте имя", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
    }
}

struct AuthButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    var backgroundColor: Color = .blue
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(backgroundColor)
        .cornerRadius(12)
        .disabled(!isEnabled || isLoading)
        .opacity((!isEnabled || isLoading) ? 0.6 : 1.0)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var foregroundColor: Color = .blue
    var borderColor: Color = .blue
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(foregroundColor)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 2)
        )
    }
}
