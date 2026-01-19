import SwiftUI

struct ChatsListView: View {
    @StateObject private var viewModel = ChatsListViewModel()
    
    var body: some View {
        // УБРАТЬ NavigationView отсюда!
        VStack {
            if viewModel.chatRooms.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("Нет чатов")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("Начни новую переписку")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.chatRooms) { room in
                        NavigationLink(destination: {
                            let otherEmail = room.participants.first { $0 != viewModel.currentUserEmail } ?? ""
                            ChatDetailView(chatRoomId: room.id ?? "", otherUserEmail: otherEmail)
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(room.participants.first { $0 != viewModel.currentUserEmail } ?? "Unknown")
                                    .font(.headline)
                                Text(room.lastMessage ?? "Нет сообщений")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        // Эти модификаторы будут работать, так как NavigationView есть в MainTabView
        .navigationTitle("Чаты")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.showNewChatSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showNewChatSheet) {
            // Используем NavigationView с .stack стилем
            NavigationView {
                NewSearchChatView(viewModel: viewModel)
            }
            .navigationViewStyle(.stack) // ← ВАЖНО: предотвращает дублирование
        }
    }
}
