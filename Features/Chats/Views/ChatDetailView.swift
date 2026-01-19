import Foundation
import SwiftUI
import FirebaseAuth

struct ChatDetailView: View {
    @StateObject private var viewModel: ChatDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let chatRoomId: String
    let otherUserEmail: String
    
    init(chatRoomId: String, otherUserEmail: String) {
        self.chatRoomId = chatRoomId
        self.otherUserEmail = otherUserEmail
        _viewModel = StateObject(wrappedValue: ChatDetailViewModel(
            chatRoomId: chatRoomId,
            otherUserEmail: otherUserEmail
        ))
    }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(otherUserEmail)
                    }
                    .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding()
            .background(Color.white)
            .shadow(radius: 2)
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(
                                message: message,
                                isCurrentUser: message.senderId == viewModel.currentUserId
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onChange(of: viewModel.messages) { _ in
                    if let lastId = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input
            HStack {
                TextField("Сообщение...", text: $viewModel.messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: { viewModel.sendMessage() }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                }
                .disabled(viewModel.messageText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.vertical)
            .background(Color.white)
        }
        .navigationBarBackButtonHidden(true)
    }
}
