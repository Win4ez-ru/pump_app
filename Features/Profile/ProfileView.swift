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
                profileHeaderView
                clientReadinessSection

                fitnessProfileSection

                BalanceCard {
                    showingPayments = true
                }

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
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 82, height: 82)

                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(profileDisplayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Spacer()

                    Button(action: { showingFitnessProfile = true }) {
                        Image(systemName: "pencil")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(width: 34, height: 34)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }

                Text("\(profileViewModel.fitnessProfile.age) лет • \(profileViewModel.fitnessProfile.gender.title)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if !profileViewModel.fitnessProfile.about.isEmpty {
                    Text(profileViewModel.fitnessProfile.about)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    ProfileStatusPill(title: authManager.hasSkippedLogin ? "Гость" : "Клиент", color: authManager.hasSkippedLogin ? .orange : .blue)
                    ProfileStatusPill(title: profileViewModel.fitnessProfile.trainingPlace.title, color: .green)
                    ProfileStatusPill(title: "\(profileViewModel.fitnessProfile.weeklyTrainingGoal)x/нед", color: .purple)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var clientReadinessSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Готовность к подбору")
                        .font(.headline)

                    Text("Чем полнее профиль, тем точнее тренеры и будущий ML-рейтинг.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("\(profileCompletion)%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }

            ProgressView(value: Double(profileCompletion), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))

            HStack(spacing: 10) {
                ReadinessItem(icon: "target", title: profileViewModel.fitnessProfile.goal.title, color: .blue)
                ReadinessItem(icon: "figure.walk", title: profileViewModel.fitnessProfile.trainingExperience.title, color: .orange)
                ReadinessItem(icon: "person.crop.circle.badge.checkmark", title: profileViewModel.fitnessProfile.preferredTrainerGender.title, color: .green)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
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
                ProfileMetricTile(icon: "ruler.fill", title: "Рост", value: "\(profileViewModel.fitnessProfile.height) см", color: .cyan)
                ProfileMetricTile(icon: "scalemass.fill", title: "Вес", value: "\(profileViewModel.fitnessProfile.weight) кг", color: .pink)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var profileDisplayName: String {
        profileViewModel.fitnessProfile.displayName.isEmpty ? (user?.displayName ?? "Гость") : profileViewModel.fitnessProfile.displayName
    }

    private var profileCompletion: Int {
        var score = 35
        if !profileViewModel.fitnessProfile.displayName.isEmpty { score += 10 }
        if !profileViewModel.fitnessProfile.about.isEmpty { score += 15 }
        if profileViewModel.fitnessProfile.height > 0 { score += 10 }
        if profileViewModel.fitnessProfile.weight > 0 { score += 10 }
        if profileViewModel.fitnessProfile.weeklyTrainingGoal > 0 { score += 10 }
        if profileViewModel.fitnessProfile.preferredTrainerGender != .any { score += 10 }
        return min(score, 100)
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

struct ProfileStatusPill: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .cornerRadius(8)
    }
}

struct ReadinessItem: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
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

                    paymentRulesCard
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
                    Text(selectedSection == .premium ? "Pump Premium" : "Тренировки")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Premium открывает функции приложения. Тренировки оплачиваются тренеру отдельно после договоренности.")
                        .font(.subheadline)
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
                PaymentMetric(title: "План", value: "Free", color: .blue)
                PaymentMetric(title: "Свайпы", value: "5/день", color: .orange)
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
            HStack {
                Text("Доступ к функциям")
                    .font(.headline)

                Spacer()

                Text("для клиента")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            PremiumComparisonCard()

            Text("Тарифы")
                .font(.headline)

            ForEach(premiumPlans) { plan in
                PremiumPlanCard(plan: plan)
            }
        }
    }

    private var trainingPaymentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Занятия с тренером")
                    .font(.headline)

                Spacer()

                Text("отдельно")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

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

    private var paymentRulesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Как устроена оплата", systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundColor(.blue)

            PaymentRuleRow(icon: "star.fill", text: "Premium влияет на поиск: больше свайпов, расширенные фильтры и сравнение тренеров.")
            PaymentRuleRow(icon: "dumbbell.fill", text: "Тренировки оплачиваются отдельно конкретному тренеру после принятия запроса.")
            PaymentRuleRow(icon: "shield.fill", text: "Для MVP это демо-экран. Реальные платежи подключаются через backend и платежный провайдер.")
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
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
            features: ["50 свайпов в день", "Возраст, стаж и достижения тренера", "Сравнение тренеров", "Расширенный прогресс"]
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

struct PremiumComparisonCard: View {
    private let rows: [(feature: String, free: String, premium: String)] = [
        ("Свайпы", "5/день", "50/день"),
        ("Фильтры", "база", "полные"),
        ("Сравнение", "-", "есть"),
        ("Прогресс", "база", "расширенный")
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Функция")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Free")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(width: 78)

                Text("Premium")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .frame(width: 88)
            }
            .padding(.bottom, 8)

            ForEach(rows, id: \.feature) { row in
                HStack {
                    Text(row.feature)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(row.free)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 78)

                    Text(row.premium)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(width: 88)
                }
                .padding(.vertical, 9)

                if row.feature != rows.last?.feature {
                    Divider()
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct PaymentRuleRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 22)

            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
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
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    editorHeader
                    personalSection
                    aboutSection
                    bodyParamsSection
                    trainingSection
                    trainerPreferenceSection
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
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

    private var editorHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Анкета для подбора")
                .font(.title2)
                .fontWeight(.bold)

            Text("Эти данные помогут показывать тренеров по цели, опыту и удобному формату тренировок.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var personalSection: some View {
        ProfileEditorCard(title: "Основное") {
            TextField("Имя", text: $draft.displayName)
                .textFieldStyle(.roundedBorder)

            Picker("Пол", selection: $draft.gender) {
                ForEach(ClientGender.allCases) { gender in
                    Text(gender.title).tag(gender)
                }
            }
            .pickerStyle(.segmented)

            ProfileStepperRow(title: "Возраст", value: "\(draft.age) лет") {
                Stepper("", value: $draft.age, in: 14...90)
                    .labelsHidden()
            }
        }
    }

    private var aboutSection: some View {
        ProfileEditorCard(title: "О себе") {
            TextEditor(text: $draft.about)
                .frame(minHeight: 104)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }

    private var bodyParamsSection: some View {
        ProfileEditorCard(title: "Параметры") {
            ProfileStepperRow(title: "Рост", value: "\(draft.height) см") {
                Stepper("", value: $draft.height, in: 120...230)
                    .labelsHidden()
            }

            ProfileStepperRow(title: "Вес", value: "\(draft.weight) кг") {
                Stepper("", value: $draft.weight, in: 35...220)
                    .labelsHidden()
            }
        }
    }

    private var trainingSection: some View {
        ProfileEditorCard(title: "Тренировки") {
            ProfileOptionGrid(title: "Цель", options: FitnessGoal.allCases, selection: $draft.goal)
            ProfileOptionGrid(title: "Формат", options: TrainingPlace.allCases, selection: $draft.trainingPlace)
            ProfileOptionGrid(title: "Опыт", options: ClientTrainingExperience.allCases, selection: $draft.trainingExperience)

            ProfileStepperRow(title: "В неделю", value: "\(draft.weeklyTrainingGoal) трен.") {
                Stepper("", value: $draft.weeklyTrainingGoal, in: 1...7)
                    .labelsHidden()
            }
        }
    }

    private var trainerPreferenceSection: some View {
        ProfileEditorCard(title: "Предпочтения") {
            ProfileOptionGrid(title: "Пол тренера", options: TrainerGender.allCases, selection: $draft.preferredTrainerGender)
        }
    }
}

struct ProfileEditorCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)

            content
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct ProfileStepperRow<Control: View>: View {
    let title: String
    let value: String
    @ViewBuilder let control: Control

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.headline)
            }

            Spacer()
            control
        }
    }
}

struct ProfileOptionGrid<Option: Identifiable & CaseIterable & Hashable>: View where Option.AllCases: RandomAccessCollection {
    let title: String
    let options: Option.AllCases
    @Binding var selection: Option

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(options) { option in
                    Button(action: { selection = option }) {
                        Text(optionTitle(option))
                            .font(.caption)
                            .fontWeight(selection == option ? .semibold : .regular)
                            .foregroundColor(selection == option ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(selection == option ? Color.blue : Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private func optionTitle(_ option: Option) -> String {
        if let goal = option as? FitnessGoal { return goal.title }
        if let place = option as? TrainingPlace { return place.title }
        if let experience = option as? ClientTrainingExperience { return experience.title }
        if let gender = option as? TrainerGender { return gender.title }
        return "\(option.id)"
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
