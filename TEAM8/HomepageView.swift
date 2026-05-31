//
//  HomeView.swift
//  Mealo
//

import SwiftUI
import SwiftData

struct HomepageView: View {

    @Query(sort: \MealLog.date, order: .reverse) private var logs: [MealLog]
    @Query private var profiles: [UserProfile]
    @State private var showLogSheet = false

    private var profile: UserProfile? { profiles.first }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12:  return "Good morning,"
        case 12..<17: return "Good afternoon,"
        case 17..<21: return "Good evening,"
        default:      return "Good night,"
        }
    }

    private var streak: Int {
        var count = 0
        var day = MealoDate.calendar.startOfDay(for: Date())
        while logs.contains(where: { MealoDate.isSameDay($0.date, day) }) {
            count += 1
            day = MealoDate.calendar.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return count
    }

    private var last7Days: [DayBarData] {
        (0..<7).reversed().compactMap { offset -> DayBarData? in
            guard let day = MealoDate.calendar.date(
                byAdding: .day, value: -offset,
                to: MealoDate.calendar.startOfDay(for: Date())
            ) else { return nil }
            let dayLogs = logs.filter { MealoDate.isSameDay($0.date, day) }
            let mood    = Dictionary(grouping: dayLogs, by: { $0.mood })
                .max(by: { $0.value.count < $1.value.count })?.key
            let label   = MealoDate.formatted(day, format: "EEE")
            return DayBarData(label: label, mood: mood, logCount: dayLogs.count)
        }
    }

    private var thisWeekLogs: [MealLog] {
        guard let ago = MealoDate.calendar.date(
            byAdding: .day, value: -6,
            to: MealoDate.calendar.startOfDay(for: Date())
        ) else { return [] }
        return logs.filter { $0.date >= ago }
    }

    private var weekAvgHour: Int? {
        let h = thisWeekLogs.map { MealoDate.calendar.component(.hour, from: $0.date) }
        return h.isEmpty ? nil : h.reduce(0, +) / h.count
    }

    private var weekHeadline: String {
        guard let avg = weekAvgHour else { return "Start logging to see\nyour pattern." }
        switch avg {
        case 5..<11:  return "You nourished yourself\nmore in the mornings."
        case 11..<15: return "You nourished yourself\nmore during slower\nafternoons."
        case 15..<19: return "You nourished yourself\nmost in the afternoons."
        default:      return "You nourished yourself\nmore in the evenings."
        }
    }

    private var weekSubtext: String {
        guard let avg = weekAvgHour else { return "" }
        switch avg {
        case 5..<11:  return "Mornings were your\nstrongest windows."
        case 11..<15: return "Afternoons were your\nstrongest windows."
        case 15..<19: return "Late afternoons were\nyour strongest windows."
        default:      return "Evenings were your\nstrongest windows."
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection
                        heroCard
                        quickLogCard
                        insightCard
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showLogSheet) {
            LogMealView { showLogSheet = false }
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
    }

    // ── Header ──────────────────────────────────────────────────────

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.custom("Georgia", size: 22)).bold()
                    .foregroundColor(Color("brown"))
                Text(profile?.name ?? "Friend")
                    .font(.custom("Georgia", size: 22)).bold()
                    .foregroundColor(Color("brown"))
            }
            Spacer()
            HStack(spacing: 16) {
                HStack(spacing: 3) {
                    Text("🔥").font(.system(size: 22))
                    if streak > 0 {
                        Text("\(streak)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("orange"))
                    }
                }
                NavigationLink(destination: InsightsView()) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color("orange"))
                }
            }
        }
    }

    // ── Hero card ────────────────────────────────────────────────────

    private var heroCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color("orange").opacity(0.45), Color("orange").opacity(0.8)],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(height: 210)
            Image("ch1")
                .resizable().scaledToFit()
                .frame(height: 190)
        }
    }

    // ── Quick log card ───────────────────────────────────────────────

    private var quickLogCard: some View {
        VStack(spacing: 16) {
            Text("Quick log")
                .font(.custom("Georgia", size: 20)).bold()
                .foregroundColor(Color("brown"))

            HStack(spacing: 10) {
                ForEach([
                    ("🌤️", "Morning\nmoment"),
                    ("☀️",  "Midday\nrefuel"),
                    ("🌙",  "Evening\nwind down")
                ], id: \.0) { icon, label in
                    Button { showLogSheet = true } label: {
                        VStack(spacing: 8) {
                            Text(icon).font(.system(size: 28))
                            Text(label)
                                .font(.system(size: 11))
                                .foregroundColor(Color("brown").opacity(0.65))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("background"))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .background(Color("CardsColor"))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // ── Insight card ─────────────────────────────────────────────────

    private var insightCard: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {

                // Left text
                VStack(alignment: .leading, spacing: 8) {
                    Text("This week's\nrhythm")
                        .font(.custom("Georgia", size: 16)).bold()
                        .foregroundColor(Color("brown"))
                    Text(weekHeadline)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color("brown"))
                    Text(weekSubtext)
                        .font(.system(size: 11))
                        .foregroundColor(Color("orange"))
                }
                .frame(width: 105, alignment: .leading)

                // Bar chart — 7 capsule bars
                HStack(alignment: .bottom, spacing: 5) {
                    ForEach(last7Days) { day in
                        VStack(spacing: 5) {
                            WeekBarView(day: day)
                            Text(day.label)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color("brown").opacity(0.55))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(18)

            // View deeper insights button
            NavigationLink(destination: InsightsView()) {
                Text("View deeper insights")
                    .font(.custom("Georgia", size: 16)).bold()
                    .foregroundColor(Color("brown"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(Color("orange").opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
        .background(Color("CardsColor"))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - DayBarData
// ─────────────────────────────────────────────────────────────────────────────

struct DayBarData: Identifiable {
    let id       = UUID()
    let label:   String
    let mood:    MoodState?
    let logCount: Int
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - WeekBarView  (capsule track + filled bottom)
// ─────────────────────────────────────────────────────────────────────────────

struct WeekBarView: View {
    let day: DayBarData

    private let trackH: CGFloat = 100
    private let minFill: CGFloat = 22
    private let maxFill: CGFloat = 80

    private var fillH: CGFloat {
        guard day.logCount > 0 else { return minFill }
        return min(minFill + CGFloat(day.logCount) * 20, maxFill)
    }

    private var color: Color {
        day.mood?.color ?? Color("button")
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Capsule()
                .fill(color.opacity(0.18))
                .frame(width: 30, height: trackH)
            Capsule()
                .fill(color)
                .frame(width: 30, height: fillH)
        }
    }
}
