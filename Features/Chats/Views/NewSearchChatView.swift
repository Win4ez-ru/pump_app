import SwiftUI
import Combine

struct NewSearchChatView: View {
    @ObservedObject var viewModel: ChatsListViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchQuery = ""
    @State private var searchResults: [User] = []
    @State private var isLoading = false
    @State private var searchCancellable: AnyCancellable?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Поисковая строка
                SearchBar(text: $searchQuery, placeholder: "Поиск по email, имени или username")
                    .padding()
                    .background(Color(.systemBackground))
                
                // Результаты поиска
                if isLoading {
                    ProgressView("Поиск...")
                        .frame(maxHeight: .infinity)
                } else if searchResults.isEmpty && !searchQuery.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Ничего не найдено")
                            .font(.headline)
                        Text("Попробуйте другой запрос")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List(searchResults) { user in
                        UserSearchRow(user: user) {
                            // Нажатие на пользователя
                            Task {
                                await viewModel.createChat(with: user)
                                dismiss()
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Новый чат")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .onChange(of: searchQuery) { newValue in
                performSearch(query: newValue)
            }
        }
    }
    
    private func performSearch(query: String) {
        searchCancellable?.cancel()
        
        if query.isEmpty {
            searchResults = []
            return
        }
        
        isLoading = true
        
        // Задержка перед поиском (debounce)
        searchCancellable = Just(query)
            .delay(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { searchText in
                Task {
                    do {
                        searchResults = try await viewModel.searchUsers(query: searchText)
                    } catch {
                        print("Ошибка поиска: \(error)")
                    }
                    isLoading = false
                }
            }
    }
}

// Компонент строки поиска
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// Компонент строки пользователя в результатах
struct UserSearchRow: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Аватар
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(user.displayName.prefix(1).uppercased())
                            .font(.headline)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Text("@\(user.username)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let email = user.email.split(separator: "@").first {
                            Text("• \(email)@...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
    }
}
