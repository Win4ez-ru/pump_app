// Features/TrainerMatching/TrainerMatchingView.swift
import SwiftUI

struct TrainerMatchingView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingAdvancedSearch = false
    @State private var showingMatchQuiz = false
    @State private var showingRequests = false
    @State private var showingTrainerDetail: Trainer?
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                profileSyncSection
                requestStatusSection
                trainerDeckSection
            }
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Подбор")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAdvancedSearch = true }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "slider.horizontal.3")

                        if hasActiveTrainerFilters {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                                .offset(x: 5, y: -5)
                        }
                    }
                }
                .accessibilityLabel("Фильтры")
            }
        }
        .sheet(isPresented: $showingAdvancedSearch) {
            AdvancedSearchView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingMatchQuiz) {
            MatchQuizView(viewModel: viewModel) { goal, place, experience, trainerGender in
                var profile = profileViewModel.fitnessProfile
                profile.goal = goal
                profile.trainingPlace = place
                profile.trainingExperience = experience
                profile.preferredTrainerGender = trainerGender
                profileViewModel.updateFitnessProfile(profile)
            }
        }
        .sheet(isPresented: $showingRequests) {
            TrainerRequestsView(viewModel: viewModel)
        }
        .sheet(item: $showingTrainerDetail) { trainer in
            TrainerDetailView(trainer: trainer, matchScore: viewModel.matchScore(for: trainer)) {
                viewModel.sendRequest(to: trainer)
            }
        }
        .onAppear {
            viewModel.applyFitnessProfile(profileViewModel.fitnessProfile)
            viewModel.startAutoScroll()
        }
        .onDisappear {
            viewModel.stopAutoScroll()
        }
        .refreshable {
            viewModel.loadData()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(width: 48, height: 48)

                    Image(systemName: "sparkles")
                        .font(.title3)
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Найдем тренера под вас")
                        .font(.headline)

                    Text(viewModel.activeMatchSummary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()
            }

            Button(action: { showingMatchQuiz = true }) {
                Label("Обновить анкету подбора", systemImage: "list.clipboard")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
        )
        .padding(.horizontal)
    }

    private var profileSyncSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.text.rectangle.fill")
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 42, height: 42)
                .background(Color(.systemGray6))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("Используем ваш фитнес-профиль")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("\(profileViewModel.fitnessProfile.goal.title), \(profileViewModel.fitnessProfile.trainingPlace.title), \(profileViewModel.fitnessProfile.weeklyTrainingGoal) трен. в неделю")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
        .padding(.horizontal)
    }

    private var requestStatusSection: some View {
        HStack(spacing: 12) {
            Button(action: { showingRequests = true }) {
                StatusMetric(icon: "paperplane.fill", value: "\(viewModel.trainerRequests.count)", title: "запросов", color: .blue)
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: { showingRequests = true }) {
                StatusMetric(icon: "clock.fill", value: "\(viewModel.pendingRequestsCount)", title: "ожидают", color: .orange)
            }
            .buttonStyle(PlainButtonStyle())

            StatusMetric(icon: "person.crop.circle.badge.checkmark", value: "\(viewModel.filteredTrainers.count)", title: "анкет", color: .green)
        }
        .padding(.horizontal)
    }

    private var hasActiveTrainerFilters: Bool {
        !viewModel.selectedFilters.isEmpty ||
        viewModel.selectedTrainerGender != .any ||
        viewModel.preferredMinAge != 24 ||
        viewModel.preferredMaxAge != 45 ||
        viewModel.minTrainerExperience != 0
    }

    private var trainerDeckSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Анкеты тренеров")
                        .font(.headline)

                    Text("Влево пропустить, вправо отправить запрос")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if !viewModel.filteredTrainers.isEmpty {
                    Text("\((viewModel.currentTrainerIndex % viewModel.filteredTrainers.count) + 1)/\(viewModel.filteredTrainers.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)

            if viewModel.filteredTrainers.isEmpty {
                EmptyTrainersView(viewModel: viewModel)
            } else if let trainer = viewModel.currentTrainer {
                TrainerSwipeCard(
                    trainer: trainer,
                    matchScore: viewModel.matchScore(for: trainer),
                    hasSentRequest: viewModel.sentRequests.contains(trainer.id),
                    dragOffset: dragOffset,
                    onTap: { showingTrainerDetail = trainer },
                    onSkip: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            dragOffset = .zero
                            viewModel.skipCurrentTrainer()
                        }
                    },
                    onRequest: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            dragOffset = .zero
                            viewModel.sendRequest(to: trainer)
                        }
                    }
                )
                .padding(.horizontal)
                .id(trainer.id)
                .offset(x: dragOffset.width, y: dragOffset.height * 0.08)
                .rotationEffect(.degrees(Double(dragOffset.width / 24)))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            handleSwipe(value.translation, trainer: trainer)
                        }
                )
            }
        }
    }

    private func handleSwipe(_ translation: CGSize, trainer: Trainer) {
        if translation.width < -90 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                viewModel.skipCurrentTrainer()
                dragOffset = .zero
            }
        } else if translation.width > 90 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                viewModel.sendRequest(to: trainer)
                dragOffset = .zero
            }
        } else {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                dragOffset = .zero
            }
        }
    }
}

struct TrainerRequestsView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.sentRequestItems.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.sentRequestItems, id: \.request.id) { item in
                            TrainerRequestCard(request: item.request, trainer: item.trainer)
                        }
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Мои запросы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "paperplane.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.6))

            Text("Запросов пока нет")
                .font(.headline)

            Text("Свайпните анкету вправо, и тренер увидит ваш запрос с целью, форматом и опытом.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

struct TrainerRequestCard: View {
    let request: TrainerRequest
    let trainer: Trainer

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                TrainerAvatarImage(trainer: trainer)
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(trainer.name)
                        .font(.headline)

                    Text(trainer.specialization)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                RequestStatusBadge(status: request.status)
            }

            Text(request.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)

            HStack(spacing: 8) {
                RequestTag(title: request.goal.title)
                RequestTag(title: request.place.title)
                RequestTag(title: request.experience.title)
            }

            HStack {
                Label(formatDate(request.createdAt), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if request.status == .accepted {
                    Label("чат открыт", systemImage: "message.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
        )
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM, HH:mm"
        return formatter.string(from: date)
    }
}

struct RequestStatusBadge: View {
    let status: TrainerRequestStatus

    var body: some View {
        Label(status.rawValue, systemImage: status.systemImage)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }

    private var color: Color {
        switch status {
        case .pending:
            return .orange
        case .accepted:
            return .green
        case .declined:
            return .red
        }
    }
}

struct RequestTag: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
}

struct StatusMetric: View {
    let icon: String
    let value: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
    }
}

struct TrainerMatchingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TrainerMatchingView()
                .environmentObject(ProfileViewModel(authService: AuthService()))
        }
    }
}
