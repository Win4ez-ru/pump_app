import SwiftUI

struct TrainerProfileDashboard: View {
    @State private var isVisibleInSearch = true
    @State private var acceptsNewClients = true
    @State private var onlineOnly = true
    @State private var showingProfileEditor = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TrainerDashboardHeader(
                    title: "Профиль тренера",
                    subtitle: "Как клиенты видят вас в подборе.",
                    icon: "person.crop.circle.fill",
                    color: .blue
                )

                profilePreviewCard

                HStack(spacing: 10) {
                    TrainerMetricTile(value: "4.9", title: "рейтинг", color: .yellow)
                    TrainerMetricTile(value: "73", title: "отзыва", color: .blue)
                    TrainerMetricTile(value: "10 мин", title: "ответ", color: .green)
                }

                searchVisibilitySection
                servicesSection
                specializationsSection
                achievementsSection
                profileQualitySection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Профиль")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingProfileEditor = true }) {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
        .sheet(isPresented: $showingProfileEditor) {
            TrainerProfileEditorView()
        }
    }

    private var profilePreviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .bottomLeading) {
                Image("trainer_6_1")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 260)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(18)

                LinearGradient(
                    colors: [.clear, .black.opacity(0.72)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .cornerRadius(18)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("Ника Морозова")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("28")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.85))
                    }

                    Text("Похудение и питание • 5 лет опыта")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))

                    HStack(spacing: 8) {
                        TrainerOverlayTag(title: "Онлайн")
                        TrainerOverlayTag(title: "2 000 ₽")
                        TrainerOverlayTag(title: "73 отзыва")
                    }
                }
                .padding(16)
            }

            Text("Помогаю начать без перегруза: тренировки дома или онлайн, мягкий контроль питания, понятные цели на неделю и поддержка между занятиями.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                TrainerProfileQuickEditButton(title: "Фото", icon: "photo.on.rectangle", color: .blue) {
                    showingProfileEditor = true
                }
                TrainerProfileQuickEditButton(title: "Описание", icon: "text.alignleft", color: .purple) {
                    showingProfileEditor = true
                }
                TrainerProfileQuickEditButton(title: "Цены", icon: "creditcard.fill", color: .green) {
                    showingProfileEditor = true
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(18)
    }

    private var searchVisibilitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Показы в подборе")
                    .font(.headline)

                Spacer()

                TrainerTag(title: "высокий шанс", color: .green)
            }

            VStack(spacing: 12) {
                TrainerToggleRow(
                    title: "Видимость в поиске",
                    subtitle: "Анкета показывается клиентам в свайпах",
                    icon: "eye.fill",
                    color: .blue,
                    isOn: $isVisibleInSearch
                )

                TrainerToggleRow(
                    title: "Беру новых клиентов",
                    subtitle: "Можно отправлять заявки и писать после матча",
                    icon: "person.badge.plus.fill",
                    color: .green,
                    isOn: $acceptsNewClients
                )

                TrainerToggleRow(
                    title: "Только онлайн",
                    subtitle: "Клиенты будут видеть онлайн-формат первым",
                    icon: "video.fill",
                    color: .purple,
                    isOn: $onlineOnly
                )
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Услуги")
                .font(.headline)

            TrainerServiceRow(title: "Пробная тренировка", subtitle: "30-45 минут, знакомство и план", price: "1 000 ₽", color: .blue)
            TrainerServiceRow(title: "Разовая тренировка", subtitle: "Онлайн или дома, техника и нагрузка", price: "2 000 ₽", color: .green)
            TrainerServiceRow(title: "Месячное ведение", subtitle: "План, чат, питание и контроль", price: "12 000 ₽", color: .purple)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var specializationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Специализации")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                TrainerSpecializationTile(icon: "figure.walk", title: "Похудение", subtitle: "мягкий старт", color: .green)
                TrainerSpecializationTile(icon: "fork.knife", title: "Питание", subtitle: "КБЖУ без стресса", color: .orange)
                TrainerSpecializationTile(icon: "house.fill", title: "Дом", subtitle: "без инвентаря", color: .blue)
                TrainerSpecializationTile(icon: "heart.fill", title: "Здоровье", subtitle: "без перегруза", color: .pink)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Достижения")
                .font(.headline)

            TrainerAchievementRow(icon: "checkmark.seal.fill", title: "Сертифицированный тренер", subtitle: "FPA, 2022", color: .blue)
            TrainerAchievementRow(icon: "star.fill", title: "73 отзыва клиентов", subtitle: "Средняя оценка 4.9", color: .yellow)
            TrainerAchievementRow(icon: "chart.line.uptrend.xyaxis", title: "82% клиентов держат регулярность", subtitle: "По данным последних 30 дней", color: .green)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var profileQualitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Готовность анкеты")
                    .font(.headline)

                Spacer()

                Text("88%")
                    .font(.headline)
                    .foregroundColor(.green)
            }

            ProgressView(value: 0.88)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))

            Text("Добавьте короткое видео-приветствие и расписание свободных окон, чтобы чаще попадать в рекомендации.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct TrainerProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = "Ника Морозова"
    @State private var age = 28.0
    @State private var experience = 5.0
    @State private var trialPrice = "1000"
    @State private var sessionPrice = "2000"
    @State private var monthlyPrice = "12000"
    @State private var bio = "Помогаю начать без перегруза: тренировки дома или онлайн, мягкий контроль питания, понятные цели на неделю и поддержка между занятиями."
    @State private var selectedFormats: Set<String> = ["Онлайн", "Дома"]
    @State private var selectedSpecializations: Set<String> = ["Похудение", "Питание", "Дом"]
    @State private var selectedWindows: Set<String> = ["Будни вечер", "Суббота утро"]

    private let formats = ["Онлайн", "Зал", "Дома", "Улица"]
    private let specializations = ["Похудение", "Питание", "Силовые", "Растяжка", "Осанка", "Бег"]
    private let windows = ["Будни утро", "Будни день", "Будни вечер", "Суббота утро", "Воскресенье"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    editorProgressCard
                    basicInfoSection
                    pricesSection
                    formatsSection
                    specializationsEditorSection
                    scheduleSection
                    previewHintSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Анкета тренера")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var editorProgressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Готовность анкеты", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundColor(.green)

                Spacer()

                Text("88%")
                    .font(.headline)
                    .foregroundColor(.green)
            }

            ProgressView(value: 0.88)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))

            Text("Для MVP эти поля достаточно собрать на фронте и потом отправлять другу в API профиля тренера.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Основное")
                .font(.headline)

            TextField("Имя", text: $name)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Возраст")
                    Spacer()
                    Text("\(Int(age))")
                        .foregroundColor(.secondary)
                }
                Slider(value: $age, in: 18...65, step: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Опыт")
                    Spacer()
                    Text("\(Int(experience)) лет")
                        .foregroundColor(.secondary)
                }
                Slider(value: $experience, in: 0...25, step: 1)
            }

            TextEditor(text: $bio)
                .frame(minHeight: 110)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var pricesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Цены")
                .font(.headline)

            TrainerPriceField(title: "Пробная", value: $trialPrice)
            TrainerPriceField(title: "Разовая", value: $sessionPrice)
            TrainerPriceField(title: "Месяц ведения", value: $monthlyPrice)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private var formatsSection: some View {
        TrainerChipEditorSection(
            title: "Форматы",
            options: formats,
            selected: $selectedFormats,
            color: .blue
        )
    }

    private var specializationsEditorSection: some View {
        TrainerChipEditorSection(
            title: "Специализации",
            options: specializations,
            selected: $selectedSpecializations,
            color: .green
        )
    }

    private var scheduleSection: some View {
        TrainerChipEditorSection(
            title: "Свободные окна",
            options: windows,
            selected: $selectedWindows,
            color: .orange
        )
    }

    private var previewHintSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Что увидит клиент", systemImage: "person.crop.rectangle.stack.fill")
                .font(.headline)
                .foregroundColor(.blue)

            Text("\(name), \(Int(age)) • \(Int(experience)) лет опыта • от \(sessionPrice) ₽")
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(bio)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct TrainerProfileQuickEditButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(color.opacity(0.12))
                .cornerRadius(11)
        }
    }
}

struct TrainerPriceField: View {
    let title: String
    @Binding var value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)

            Spacer()

            TextField("0", text: $value)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 90)

            Text("₽")
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TrainerChipEditorSection: View {
    let title: String
    let options: [String]
    @Binding var selected: Set<String>
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button(action: { toggle(option) }) {
                        HStack {
                            Text(option)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(1)

                            Spacer()

                            Image(systemName: selected.contains(option) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selected.contains(option) ? color : .secondary.opacity(0.6))
                        }
                        .foregroundColor(selected.contains(option) ? color : .primary)
                        .padding(12)
                        .background(selected.contains(option) ? color.opacity(0.12) : Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    private func toggle(_ option: String) {
        if selected.contains(option) {
            selected.remove(option)
        } else {
            selected.insert(option)
        }
    }
}

struct TrainerOverlayTag: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.2))
            .cornerRadius(9)
    }
}

struct TrainerToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

struct TrainerServiceRow: View {
    let title: String
    let subtitle: String
    let price: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.14))
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: "creditcard.fill")
                        .font(.subheadline)
                        .foregroundColor(color)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(price)
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TrainerSpecializationTile: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)

            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TrainerAchievementRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}
