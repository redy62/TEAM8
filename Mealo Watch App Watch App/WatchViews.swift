//
//  Untitled.swift
//  Mealo
//
//  Created by Rahaf on 01/06/2026.
//
//
//  WatchViews.swift
//  Mealo Watch App
//

import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Shared Watch Colors
// ─────────────────────────────────────────────────────────────────────────────

private let wOrange = Color(red: 0.91, green: 0.45, blue: 0.32)
private let wGreen  = Color(red: 0.55, green: 0.72, blue: 0.55)
private let wYellow = Color(red: 0.97, green: 0.85, blue: 0.45)
private let wPink   = Color(red: 0.98, green: 0.82, blue: 0.82)
private let wBg     = Color.black

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Watch Models
// ─────────────────────────────────────────────────────────────────────────────

struct WatchMealSlot: Identifiable {
    let id    = UUID()
    let icon:  String
    let label: String
    var logged: Bool = false
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - 1. State View
// "You're doing great!" + orange character + "Keep it up!"
// ─────────────────────────────────────────────────────────────────────────────

struct WatchStateView: View {

    @State private var meals: [WatchMealSlot] = WatchStateView.defaultMeals()
    @AppStorage("watchStreak") private var streak: Int = 0

    private static func defaultMeals() -> [WatchMealSlot] {[
        WatchMealSlot(icon: "🌤️", label: "Breakfast"),
        WatchMealSlot(icon: "☀️",  label: "Lunch"),
        WatchMealSlot(icon: "🌅",  label: "Dinner"),
        WatchMealSlot(icon: "🌙",  label: "Snack"),
    ]}

    private var loggedCount: Int { meals.filter { $0.logged }.count }

    private var stateMessage: String {
        switch loggedCount {
        case 0:            return "Ready to start\nyour day!"
        case meals.count:  return "You crushed it\ntoday! 🎉"
        default:           return "You're doing\ngreat!"
        }
    }

    var body: some View {
        ZStack {
            wBg.ignoresSafeArea()
            VStack(spacing: 6) {
                Image("ch1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 54)

                Text(stateMessage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Keep it up! ♥")
                    .font(.system(size: 11))
                    .foregroundColor(wOrange)
            }
            .padding()
        }
        .navigationTitle("State")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - 2. Log Food View
// "What did you have?" grid of 4 meal buttons
// ─────────────────────────────────────────────────────────────────────────────

struct WatchLogFoodView: View {

    @State private var meals: [WatchMealSlot] = [
        WatchMealSlot(icon: "🍞", label: "Breakfast"),
        WatchMealSlot(icon: "🥗", label: "Lunch"),
        WatchMealSlot(icon: "🍕", label: "Dinner"),
        WatchMealSlot(icon: "🍎", label: "Snack"),
    ]
    @State private var tappedID: UUID? = nil

    var body: some View {
        ZStack {
            wBg.ignoresSafeArea()
            VStack(spacing: 6) {
                Text("What did you\nhave?")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 6),
                    GridItem(.flexible(), spacing: 6)
                ], spacing: 6) {
                    ForEach($meals) { $meal in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                meal.logged.toggle()
                                tappedID = meal.id
                            }
                        } label: {
                            VStack(spacing: 3) {
                                Text(meal.icon)
                                    .font(.system(size: 20))
                                Text(meal.label)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(meal.logged ? .black : .white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(meal.logged ? wOrange : Color.white.opacity(0.12))
                            )
                        }
                        .buttonStyle(.plain)
                        .scaleEffect(tappedID == meal.id ? 0.92 : 1.0)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .navigationTitle("Log Food")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - 3. Streak View
// Fire icon + "X days in a row"
// ─────────────────────────────────────────────────────────────────────────────

struct WatchStreakView: View {

    @AppStorage("watchStreak") private var streak: Int = 0
    @State private var animating = false

    var body: some View {
        ZStack {
            wBg.ignoresSafeArea()
            VStack(spacing: 8) {
                Text("You're on fire!")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                ZStack {
                    // Glow
                    Circle()
                        .fill(wOrange.opacity(0.15))
                        .frame(width: 70, height: 70)
                        .scaleEffect(animating ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                                   value: animating)

                    Text("🔥")
                        .font(.system(size: 44))
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(max(streak, 1))")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(wOrange)
                    Text("days in a row")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
        }
        .onAppear { animating = true }
        .navigationTitle("Streak")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - 4. Analytics View
// Paged: Today count / This week bar chart
// ─────────────────────────────────────────────────────────────────────────────

struct WatchAnalyticsView: View {

    @AppStorage("watchLoggedToday") private var loggedToday: Int = 0
    @AppStorage("watchDailyGoal")   private var dailyGoal:   Int = 4
    @AppStorage("watchTotalMeals")  private var totalMeals:  Int = 0
    @AppStorage("watchGoalMeals")   private var goalMeals:   Int = 20

    // Last 7 days bar data — stored as comma-separated ints
    @AppStorage("watchWeekData") private var weekDataStr: String = "0,0,0,0,0,0,0"

    private var weekData: [Int] {
        weekDataStr.split(separator: ",").compactMap { Int($0) }
    }

    private let dayLabels = ["S","M","T","W","T","F","S"]
    private let barColors: [Color] = [wGreen, wPink, wOrange, wYellow, wOrange, wGreen, wPink]

    @State private var meals: [WatchMealSlot] = [
        WatchMealSlot(icon: "🍞", label: "Breakfast"),
        WatchMealSlot(icon: "🥗", label: "Lunch"),
        WatchMealSlot(icon: "🍕", label: "Dinner"),
        WatchMealSlot(icon: "🥤", label: "Snack"),
    ]

    var body: some View {
        TabView {
            // Page 1 — Today
            todayPage
            // Page 2 — Today with full goal
            todayFullPage
            // Page 3 — This week
            weekPage
        }
        .tabViewStyle(.page)
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var todayPage: some View {
        ZStack {
            wBg.ignoresSafeArea()
            VStack(spacing: 6) {
                Text("Today")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(loggedToday)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(wGreen)
                    Text("/ \(dailyGoal)")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.6))
                }

                Text("Meals logged")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))

                mealIconRow
            }
            .padding(.horizontal, 6)
        }
    }

    private var todayFullPage: some View {
        ZStack {
            wBg.ignoresSafeArea()
            VStack(spacing: 6) {
                Text("Today")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(dailyGoal)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(wOrange)
                    Text("/ \(dailyGoal)")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.6))
                }

                Text("Meals logged")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))

                mealIconRow
            }
            .padding(.horizontal, 6)
        }
    }

    private var mealIconRow: some View {
        HStack(spacing: 5) {
            ForEach(meals) { meal in
                VStack(spacing: 2) {
                    Text(meal.icon)
                        .font(.system(size: 16))
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(wYellow.opacity(0.25))
                        )
                    Text(meal.label)
                        .font(.system(size: 7))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
    }

    private var weekPage: some View {
        ZStack {
            wBg.ignoresSafeArea()
            VStack(spacing: 6) {
                Text("This week")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)

                // Bar chart
                HStack(alignment: .bottom, spacing: 5) {
                    ForEach(Array(zip(weekData.indices, weekData)), id: \.0) { i, count in
                        VStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(barColors[i % barColors.count])
                                .frame(width: 18,
                                       height: count > 0 ? CGFloat(count) * 10 + 10 : 6)
                            Text(dayLabels[i % dayLabels.count])
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .frame(height: 60, alignment: .bottom)

                // Total meals
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total Meals")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(totalMeals) / \(goalMeals)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 8)
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Previews
// ─────────────────────────────────────────────────────────────────────────────

#Preview("State") { WatchStateView() }
#Preview("Log Food") { WatchLogFoodView() }
#Preview("Streak") { WatchStreakView() }
#Preview("Analytics") { WatchAnalyticsView() }

