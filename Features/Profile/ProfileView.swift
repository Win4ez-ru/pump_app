import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthService
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingEditProfile = false
    @State private var showingFitnessProfile = false
    @State private var showingNotifications = false
    @State private var showingPrivacySettings = false
    @State private var showingPayments = false
    
    private var user: User? {
        authManager.currentUser
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile header
                profileHeaderView
                
                // User balance
                BalanceCard {
                    showingPayments = true
                }

                fitnessProfileSection

                // Основные настройки (ВЗЯТО ИЗ SETTINGSVIEW)
                VStack(alignment: .leading, spacing: 15) {
                    Text("Основные")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    SettingsRow(
                        icon: "bell.fill",
                        title: "Уведомления",
                        subtitle: "\(viewModel.notifications.filter { $0.isUnread }.count) новых • тренировки, шаги, сообщения"
                    )
                    .onTapGesture {
                        showingNotifications = true
                    }

                    SettingsRow(
                        icon: "eye.fill",
                        title: "Приватность",
                        subtitle: "Настройки конфиденциальности"
                    )
                    .onTapGesture {
                        showingPrivacySettings = true
                    }
                    
                    SettingsRow(
                        icon: "paintbrush.fill",
                        title: "Тема",
                        subtitle: "Светлая / Темная",
                        hasSwitch: true,
                        isOn: $viewModel.isDarkModeEnabled
                    )
                }
                
                // Аккаунт (ВЗЯТО ИЗ SETTINGSVIEW)
                VStack(alignment: .leading, spacing: 15) {
                    Text("Аккаунт")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    SettingsRow(
                        icon: "figure.strengthtraining.traditional",
                        title: "Фитнес-профиль",
                        subtitle: "Цель, опыт, параметры и предпочтения"
                    )
                    .onTapGesture {
                        showingFitnessProfile = true
                    }

                    SettingsRow(
                        icon: "person.fill",
                        title: "Данные аккаунта",
                        subtitle: "Изменить email, пароль"
                    )
                    .onTapGesture {
                        showingEditProfile = true
                    }
                    
                    SettingsRow(
                        icon: "creditcard.fill",
                        title: "Платежи",
                        subtitle: "Premium, пакеты тренировок и история"
                    )
                    .onTapGesture {
                        showingPayments = true
                    }
                    
                    if authManager.hasSkippedLogin {
                        SettingsRow(
                            icon: "person.badge.plus",
                            title: "Зарегистрироваться",
                            subtitle: "Создать аккаунт",
                            color: .blue
                        )
                    }
                }
                
                // О приложении (ВЗЯТО ИЗ SETTINGSVIEW)
                VStack(alignment: .leading, spacing: 15) {
                    Text("О приложении")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    SettingsRow(
                        icon: "info.circle.fill",
                        title: "Версия",
                        subtitle: "1.0.0"
                    )
                    
                    SettingsRow(
                        icon: "shield.fill",
                        title: "Политика конфиденциальности",
                        subtitle: "Как мы используем ваши данные"
                    )
                    
                    SettingsRow(
                        icon: "doc.text.fill",
                        title: "Условия использования",
                        subtitle: "Правила сервиса"
                    )
                }
                
                // Информация о текущем режиме (ВЗЯТО ИЗ SETTINGSVIEW)
                if authManager.hasSkippedLogin {
                    VStack(spacing: 10) {
                        Text("Гостевой режим")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("Некоторые функции ограничены. Для полного доступа зарегистрируйтесь.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Logout button
                if authManager.isAuthenticated {
                    logoutButton
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Профиль")
        .onAppear {
            viewModel.loadSettings()
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingFitnessProfile) {
            FitnessProfileEditView(
                profile: profileViewModel.fitnessProfile,
                onSave: { profile in
                    profileViewModel.updateFitnessProfile(profile)
                }
            )
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationsCenterView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingPrivacySettings) {
            PrivacySettingsView()
        }
        .sheet(isPresented: $showingPayments) {
            PaymentsView()
        }
    }
    
    private var profileHeaderView: some View {
        VStack(spacing: 15) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 5) {
                Text(profileViewModel.fitnessProfile.displayName.isEmpty ? (user?.displayName ?? "Гость") : profileViewModel.fitnessProfile.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let email = user?.email {
                    Text(email)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            if authManager.hasSkippedLogin {
                Text("Гостевой режим")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var fitnessProfileSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Фитнес-профиль")
                    .font(.headline)

                Spacer()

                Button(action: { showingFitnessProfile = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }

            Text(profileViewModel.fitnessProfile.about)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ProfileMetricTile(icon: "target", title: "Цель", value: profileViewModel.fitnessProfile.goal.title, color: .blue)
                ProfileMetricTile(icon: "location.fill", title: "Формат", value: profileViewModel.fitnessProfile.trainingPlace.title, color: .green)
                ProfileMetricTile(icon: "chart.bar.fill", title: "Опыт", value: profileViewModel.fitnessProfile.trainingExperience.title, color: .purple)
                ProfileMetricTile(icon: "calendar.badge.clock", title: "В неделю", value: "\(profileViewModel.fitnessProfile.weeklyTrainingGoal) трен.", color: .orange)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var logoutButton: some View {
        Button(action: {
            try? authManager.signOut()
        }) {
            Text("Выйти")
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

struct ProfileMetricTile: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .topLeading)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - SettingsRow (ВЗЯТО ИЗ SETTINGSVIEW)
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var hasSwitch: Bool = false
    var color: Color = .blue
    @Binding var isOn: Bool
    
    init(icon: String, title: String, subtitle: String, hasSwitch: Bool = false, color: Color = .blue, isOn: Binding<Bool> = .constant(true)) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.hasSwitch = hasSwitch
        self.color = color
        self._isOn = isOn
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if hasSwitch {
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}


// MARK: - Placeholder Views
struct PaymentsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection: PaymentSection = .premium
    @State private var selectedPackageID: String?

    private let premiumPlans = PremiumPlan.demo
    private let trainingPackages = TrainingPackage.demo
    private let payments = PaymentHistoryItem.demo

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    paymentHeader
                    sectionPicker

                    if selectedSection == .premium {
                        premiumSection
                    } else {
                        trainingPaymentsSection
                    }

                    historySection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Платежи")
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

    private var paymentHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Раздельная оплата")
                        .font(.headline)

                    Text("Premium открывает функции приложения. Тренировки оплачиваются тренеру отдельно.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }

                Spacer()

                Image(systemName: "creditcard.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }

            HStack(spacing: 10) {
                PaymentMetric(title: "Баланс", value: "1 500 ₽", color: .green)
                PaymentMetric(title: "Premium", value: "Free", color: .blue)
                PaymentMetric(title: "Занятий", value: "2", color: .orange)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var sectionPicker: some View {
        Picker("Раздел", selection: $selectedSection) {
            ForEach(PaymentSection.allCases) { section in
                Text(section.title).tag(section)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pump Premium")
                .font(.headline)

            ForEach(premiumPlans) { plan in
                PremiumPlanCard(plan: plan)
            }
        }
    }

    private var trainingPaymentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Оплата тренеру")
                .font(.headline)

            Text("Эти платежи относятся к реальным персональным тренировкам. В будущем здесь будет Apple Pay/карта и комиссия платформы.")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(trainingPackages) { package in
                TrainingPackageCard(
                    package: package,
                    isSelected: selectedPackageID == package.id
                ) {
                    selectedPackageID = package.id
                }
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("История")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(payments) { item in
                    PaymentHistoryRow(item: item)

                    if item.id != payments.last?.id {
                        Divider()
                            .padding(.leading, 46)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }
}

enum PaymentSection: String, CaseIterable, Identifiable {
    case premium
    case trainings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .premium:
            return "Premium"
        case .trainings:
            return "Тренировки"
        }
    }
}

struct PremiumPlan: Identifiable {
    let id: String
    let title: String
    let price: String
    let period: String
    let badge: String?
    let features: [String]

    static let demo = [
        PremiumPlan(
            id: "free",
            title: "Free",
            price: "0 ₽",
            period: "всегда",
            badge: "сейчас",
            features: ["5 свайпов в день", "Базовые фильтры", "Чат после принятия запроса"]
        ),
        PremiumPlan(
            id: "premium",
            title: "Pump Premium",
            price: "299 ₽",
            period: "месяц",
            badge: "лучший выбор",
            features: ["Больше свайпов", "Расширенные фильтры", "Сравнение тренеров", "Расширенный прогресс"]
        )
    ]
}

struct TrainingPackage: Identifiable {
    let id: String
    let title: String
    let trainerName: String
    let price: String
    let subtitle: String
    let discount: String?

    static let demo = [
        TrainingPackage(id: "trial", title: "Пробная тренировка", trainerName: "Ника Морозова", price: "750 ₽", subtitle: "1 занятие • 50% скидка", discount: "-50%"),
        TrainingPackage(id: "four", title: "Пакет 4 тренировки", trainerName: "Ника Морозова", price: "5 600 ₽", subtitle: "4 занятия • действует 30 дней", discount: nil),
        TrainingPackage(id: "eight", title: "Пакет 8 тренировок", trainerName: "Ника Морозова", price: "10 400 ₽", subtitle: "8 занятий • выгоднее на 15%", discount: "-15%")
    ]
}

struct PaymentHistoryItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let amount: String
    let date: String
    let type: PaymentHistoryType

    static let demo = [
        PaymentHistoryItem(id: "1", title: "Пополнение баланса", subtitle: "Карта •••• 2148", amount: "+1 500 ₽", date: "Сегодня", type: .topUp),
        PaymentHistoryItem(id: "2", title: "Пробная тренировка", subtitle: "Ника Морозова", amount: "-750 ₽", date: "Вчера", type: .training),
        PaymentHistoryItem(id: "3", title: "Pump Premium", subtitle: "Демо-подписка", amount: "299 ₽", date: "12.05", type: .premium)
    ]
}

enum PaymentHistoryType {
    case topUp
    case training
    case premium

    var icon: String {
        switch self {
        case .topUp:
            return "plus.circle.fill"
        case .training:
            return "dumbbell.fill"
        case .premium:
            return "star.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .topUp:
            return .green
        case .training:
            return .blue
        case .premium:
            return .purple
        }
    }
}

struct PaymentMetric: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct PremiumPlanCard: View {
    let plan: PremiumPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.title)
                            .font(.headline)

                        if let badge = plan.badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }

                    Text("\(plan.price) / \(plan.period)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(plan.id == "free" ? "Активен" : "Подключить") {}
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(plan.id == "free" ? .green : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(plan.id == "free" ? Color.green.opacity(0.12) : Color.blue)
                    .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(plan.features, id: \.self) { feature in
                    Label(feature, systemImage: "checkmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct TrainingPackageCard: View {
    let package: TrainingPackage
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(width: 42, height: 42)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(package.title)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if let discount = package.discount {
                            Text(discount)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(7)
                        }
                    }

                    Text(package.trainerName)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(package.subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(package.price)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .green : .secondary)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PaymentHistoryRow: View {
    let item: PaymentHistoryItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.type.icon)
                .foregroundColor(item.type.color)
                .frame(width: 34, height: 34)
                .background(item.type.color.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(item.amount)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(item.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("Редактирование профиля")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle("Редактировать профиль")
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
}

struct FitnessProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: ClientFitnessProfile
    let onSave: (ClientFitnessProfile) -> Void

    init(profile: ClientFitnessProfile, onSave: @escaping (ClientFitnessProfile) -> Void) {
        _draft = State(initialValue: profile)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Основное") {
                    TextField("Имя", text: $draft.displayName)

                    Picker("Пол", selection: $draft.gender) {
                        ForEach(ClientGender.allCases) { gender in
                            Text(gender.title).tag(gender)
                        }
                    }

                    Stepper("Возраст: \(draft.age)", value: $draft.age, in: 14...90)
                }

                Section("О себе") {
                    TextEditor(text: $draft.about)
                        .frame(minHeight: 90)
                }

                Section("Параметры") {
                    Stepper("Рост: \(draft.height) см", value: $draft.height, in: 120...230)
                    Stepper("Вес: \(draft.weight) кг", value: $draft.weight, in: 35...220)
                }

                Section("Тренировки") {
                    Picker("Цель", selection: $draft.goal) {
                        ForEach(FitnessGoal.allCases) { goal in
                            Text(goal.title).tag(goal)
                        }
                    }

                    Picker("Где тренироваться", selection: $draft.trainingPlace) {
                        ForEach(TrainingPlace.allCases) { place in
                            Text(place.title).tag(place)
                        }
                    }

                    Picker("Опыт", selection: $draft.trainingExperience) {
                        ForEach(ClientTrainingExperience.allCases) { experience in
                            Text(experience.title).tag(experience)
                        }
                    }

                    Stepper("Тренировок в неделю: \(draft.weeklyTrainingGoal)", value: $draft.weeklyTrainingGoal, in: 1...7)
                }

                Section("Предпочтения") {
                    Picker("Пол тренера", selection: $draft.preferredTrainerGender) {
                        ForEach(TrainerGender.allCases) { gender in
                            Text(gender.title).tag(gender)
                        }
                    }
                }
            }
            .navigationTitle("Фитнес-профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        onSave(draft)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct NotificationsCenterView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingPreferences = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    notificationSummary

                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.notifications) { notification in
                            NotificationCard(notification: notification)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Уведомления")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Готово") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingPreferences = true }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showingPreferences) {
                NotificationPreferencesView(
                    preferences: viewModel.notificationPreferences,
                    onSave: { preferences in
                        viewModel.updateNotificationPreferences(preferences)
                    }
                )
            }
        }
    }

    private var notificationSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Центр уведомлений")
                    .font(.headline)

                Spacer()

                Button("Прочитано") {
                    viewModel.markAllNotificationsRead()
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            }

            HStack(spacing: 10) {
                NotificationMetric(value: "\(viewModel.notifications.filter { $0.isUnread }.count)", title: "новых", color: .blue)
                NotificationMetric(value: viewModel.notificationPreferences.trainingReminders ? "Вкл" : "Выкл", title: "тренировки", color: .green)
                NotificationMetric(value: "\(viewModel.notificationPreferences.reminderMinutesBeforeTraining) мин", title: "до старта", color: .orange)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct NotificationMetric: View {
    let value: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct NotificationCard: View {
    let notification: ClientNotification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: notification.type.icon)
                    .font(.headline)
                    .foregroundColor(color)
                    .frame(width: 42, height: 42)
                    .background(color.opacity(0.12))
                    .clipShape(Circle())

                if notification.isUnread {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 9, height: 9)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(notification.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Spacer()

                    Text(formatTime(notification.time))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Text(notification.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                Text(notification.type.rawValue)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }

    private var color: Color {
        switch notification.type {
        case .training:
            return .blue
        case .message:
            return .green
        case .activity:
            return .orange
        case .achievement:
            return .purple
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "dd.MM"
        }
        return formatter.string(from: date)
    }
}

struct NotificationPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: NotificationPreferences
    let onSave: (NotificationPreferences) -> Void

    init(preferences: NotificationPreferences, onSave: @escaping (NotificationPreferences) -> Void) {
        _draft = State(initialValue: preferences)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section("События") {
                    Toggle("Тренировки", isOn: $draft.trainingReminders)
                    Toggle("Сообщения тренера", isOn: $draft.trainerMessages)
                    Toggle("Цель по шагам", isOn: $draft.stepGoalReminders)
                    Toggle("КБЖУ и питание", isOn: $draft.nutritionReminders)
                    Toggle("Достижения", isOn: $draft.achievementAlerts)
                }

                Section("Тренировки") {
                    Stepper(
                        "Напоминать за \(draft.reminderMinutesBeforeTraining) мин",
                        value: $draft.reminderMinutesBeforeTraining,
                        in: 15...180,
                        step: 15
                    )
                }

                Section("Тихие часы") {
                    Toggle("Не беспокоить ночью", isOn: $draft.quietHoursEnabled)
                    Stepper("С \(draft.quietHoursStart):00", value: $draft.quietHoursStart, in: 0...23)
                    Stepper("До \(draft.quietHoursEnd):00", value: $draft.quietHoursEnd, in: 0...23)
                }
            }
            .navigationTitle("Настройки уведомлений")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        onSave(draft)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Настройки приватности")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle("Приватность")
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
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
                .environmentObject(AuthService())
                .environmentObject(ProfileViewModel(authService: AuthService()))
        }
    }
}
