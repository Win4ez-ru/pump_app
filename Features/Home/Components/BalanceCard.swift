// Features/Home/Components/BalanceCard.swift
import SwiftUI

struct BalanceCard: View {
    var balance: Double = 1500.0
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Баланс")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(balance, specifier: "%.0f") ₽")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "creditcard.fill")
                    .font(.title3)
                    .foregroundColor(.green)
            }
            
            Text("Доступно для оплаты тренировок и консультаций")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: 12) {
                SecondaryButton(
                    title: "Пополнить",
                    action: {
                        onTap?()
                    }
                )
                
                PrimaryButton(
                    title: "История",
                    action: {
                        onTap?()
                    }
                )
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

// MARK: - Previews
struct BalanceCard_Previews: PreviewProvider {
    static var previews: some View {
        BalanceCard(balance: 1500.0, onTap: {})
            .padding()
    }
}
