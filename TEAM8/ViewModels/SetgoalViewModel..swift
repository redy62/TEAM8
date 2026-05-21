//
//  Setgoal.swift
//  TEAM8
//
//  Created by ريناد محمد حملي on 02/12/1447 AH.
//

import SwiftUI

// MARK: - Models & Data
struct MealEntry: Identifiable {
    let id = UUID()
    var icon: String
    var label: String
    var startTime: Date
    var endTime: Date
    var iconActivated: Bool = false
    var timeActivated: Bool = false
}

let mealIcons: [(emoji: String, label: String, defaultHour: Int)] = [
    ("🌙", "Night snack",   21),
    ("🌤️", "Morning meal",   8),
    ("☀️",  "Midday meal",   12),
    ("🌅",  "Evening meal",  18),
    ("🍎",  "Snack",         15),
    ("🥗",  "Light meal",    17),
    ("🫖",  "Tea time",      16),
    ("🥞",  "Brunch",        10),
]

// MARK: - PAGE 1: Set Your Plan View
struct SetYourPlanView: View {
    var onDone: () -> Void
    
    @State private var mealCount: Double = 0
    @State private var meals: [MealEntry] = []
    @State private var selectedDays: Int? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text("Set your plan")
                            .font(.custom("Georgia", size: 26))
                            .foregroundColor(Color("orange"))
                            .padding(.bottom, 4)
                        
                        Text("How many meals do you want to track each day?")
                            .font(.system(size: 12))
                            .foregroundColor(Color("orange").opacity(0.45))
                            .padding(.bottom, 24)
                        
                        sliderSection
                        
                        if !meals.isEmpty {
                            howLongSection
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        Spacer(minLength: 40)
                        
                        // زر الانتقال للصفحة الثانية
                        if !meals.isEmpty && selectedDays != nil {
                            NavigationLink {
                                CustomizeMealsView(meals: $meals, onDone: onDone)
                            } label: {
                                Text("Next: Customize Meals →")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color("orange"))
                                    .clipShape(Capsule())
                            }
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 56)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    // MARK: Slider
    var sliderSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MEALS PER DAY")
                .font(.system(size: 11))
                .foregroundColor(Color("orange").opacity(0.45))
                .kerning(1.2)
            
            Slider(value: $mealCount, in: 1...6, step: 1)
                .tint(Color("orange"))
                .onChange(of: mealCount) { newVal in
                    let count = Int(newVal)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        if count > meals.count {
                            for i in meals.count..<count {
                                let ic = mealIcons[i % mealIcons.count]
                                meals.append(MealEntry(
                                    icon: ic.emoji,
                                    label: ic.label,
                                    startTime: makeTime(hour: ic.defaultHour),
                                    endTime:   makeTime(hour: ic.defaultHour + 1)
                                ))
                            }
                        } else {
                            meals.removeLast(meals.count - count)
                        }
                    }
                }
            
            HStack {
                ForEach(1...6, id: \.self) { n in
                    Text("\(n)")
                        .font(.system(size: 10, weight: Int(mealCount) >= n ? .semibold : .regular))
                        .foregroundColor(Int(mealCount) >= n ? Color("orange") : Color("orange").opacity(0.35))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: How Long
    var howLongSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How long?")
                .font(.system(size: 12))
                .foregroundColor(Color("orange").opacity(0.45))
            
            HStack(spacing: 8) {
                ForEach([30, 66, 90], id: \.self) { days in
                    Button {
                        withAnimation { selectedDays = days }
                    } label: {
                        Text("\(days) Days")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(selectedDays == days ? .white : Color("orange"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(selectedDays == days ? Color("orange") : Color("orange").opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color("orange").opacity(0.25), lineWidth: 1.5)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
        }
        .padding(.bottom, 28)
    }
}

// MARK: - PAGE 2: Customize Meals View (صفحة البوكسات)
struct CustomizeMealsView: View {
    @Binding var meals: [MealEntry]
    var onDone: () -> Void
    
    @State private var activeMealIndex: Int? = nil
    
    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("Customize your meals")
                        .font(.custom("Georgia", size: 26))
                        .foregroundColor(Color("orange"))
                        .padding(.bottom, 4)
                    
                    Text("Set the icons and times for your daily meals.")
                        .font(.system(size: 12))
                        .foregroundColor(Color("orange").opacity(0.45))
                        .padding(.bottom, 24)
                    
                    // بوكسات الوجبات
                    VStack(spacing: 10) {
                        ForEach(meals.indices, id: \.self) { i in
                            MealBoxView(
                                meal: $meals[i],
                                onTimeTap: { activeMealIndex = i }
                            )
                        }
                    }
                    .padding(.bottom, 32)
                    
                    // زر إنهاء الرحلة
                    Button(action: onDone) {
                        Text("Start my journey →")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color("orange"))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        // إخفاء زر الرجوع الافتراضي لو حاب، أو تخليه زي ما هو
        // .navigationBarBackButtonHidden(true)
        .sheet(item: Binding(
            get: { activeMealIndex.map { IdentifiableIndex(value: $0) } },
            set: { activeMealIndex = $0?.value }
        )) { idx in
            TimePicker(meal: $meals[idx.value])
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - MealBoxView (لم يتغير)
struct MealBoxView: View {
    @Binding var meal: MealEntry
    var onTimeTap: () -> Void
    
    @GestureState private var dragOffset: CGFloat = 0
    @State private var dragStartIndex: Int = 0
    
    var currentIndex: Int {
        mealIcons.firstIndex(where: { $0.emoji == meal.icon }) ?? 0
    }
    
    var body: some View {
        HStack(spacing: 0) {
            
            // ── Icon Picker ──
            ZStack {
                if meal.iconActivated {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("orange").opacity(0.15), lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
                
                VStack(spacing: 0) {
                    Text(currentIndex > 0 ? mealIcons[currentIndex - 1].emoji : " ")
                        .font(.system(size: 18))
                        .opacity(0.3)
                        .frame(height: 28)
                    
                    Text(meal.icon)
                        .font(.system(size: meal.iconActivated ? 24 : 22))
                        .frame(height: 28)
                        .scaleEffect(meal.iconActivated ? 1.15 : 1.0)
                    
                    Text(currentIndex < mealIcons.count - 1 ? mealIcons[currentIndex + 1].emoji : " ")
                        .font(.system(size: 18))
                        .opacity(0.3)
                        .frame(height: 28)
                }
                .mask(
                    LinearGradient(
                        colors: [.clear, .black, .black, .clear],
                        startPoint: .top, endPoint: .bottom
                    )
                )
            }
            .frame(width: 52, height: meal.iconActivated ? 52 : 60)
            .padding(.leading, meal.iconActivated ? 8 : 0)
            .padding(.vertical, meal.iconActivated ? 4 : 0)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: meal.iconActivated)
            .gesture(
                DragGesture()
                    .onChanged { val in
                        if !meal.iconActivated {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                meal.iconActivated = true
                            }
                            dragStartIndex = currentIndex
                        }
                        if abs(val.translation.height) < 5 {
                            dragStartIndex = currentIndex
                        }
                        let delta = Int((-val.translation.height) / 20)
                        let newIdx = max(0, min(mealIcons.count - 1, dragStartIndex + delta))
                        if newIdx != currentIndex {
                            withAnimation(.easeOut(duration: 0.12)) {
                                meal.icon  = mealIcons[newIdx].emoji
                                meal.label = mealIcons[newIdx].label
                            }
                        }
                    }
            )
            
            if !meal.iconActivated {
                Rectangle()
                    .fill(Color("orange").opacity(0.15))
                    .frame(width: 1, height: 40)
                    .padding(.horizontal, 10)
                    .transition(.opacity)
            } else {
                Spacer().frame(width: 10)
            }
            
            // ── Meal Info ──
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color("orange").opacity(0.85))
                Text(meal.iconActivated ? "tap time →" : "↕ scroll to pick")
                    .font(.system(size: 10))
                    .foregroundColor(Color("orange").opacity(0.35))
                    .animation(.easeInOut(duration: 0.2), value: meal.iconActivated)
            }
            
            Spacer()
            
            // ── Time Badge ──
            Button(action: onTimeTap) {
                if meal.timeActivated {
                    VStack(spacing: 2) {
                        Text(formatTime(meal.startTime))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color("green"))
                        Text(formatTime(meal.endTime))
                            .font(.system(size: 9))
                            .foregroundColor(Color("orange").opacity(0.4))
                    }
                    .frame(width: 52, height: 52)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("green").opacity(0.3), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                } else {
                    Text("2h")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color("green"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color.white)
                        .overlay(
                            Capsule().stroke(Color("green").opacity(0.4), lineWidth: 1.5)
                        )
                        .clipShape(Capsule())
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: meal.timeActivated)
            .padding(.trailing, 0)
        }
        .padding(.leading, 0)
        .padding(.trailing, 14)
        .padding(.vertical, 10)
        .background(Color("orange").opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("green").opacity(0.3), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - TimePicker Sheet (لم يتغير)
struct TimePicker: View {
    @Binding var meal: MealEntry
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Set reminder window")
                .font(.custom("Georgia", size: 16))
                .foregroundColor(Color("orange"))
                .padding(.top, 20)
            
            Text("Pick start & end time")
                .font(.system(size: 11))
                .foregroundColor(Color("orange").opacity(0.45))
                .padding(.bottom, 8)
            
            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("START")
                        .font(.system(size: 10))
                        .foregroundColor(Color("orange").opacity(0.45))
                        .kerning(1)
                    DatePicker("", selection: $meal.startTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(width: 150)
                        .tint(Color("orange"))
                }
                
                Text("→")
                    .foregroundColor(Color("orange").opacity(0.4))
                    .padding(.top, 16)
                
                VStack(spacing: 4) {
                    Text("END")
                        .font(.system(size: 10))
                        .foregroundColor(Color("orange").opacity(0.45))
                        .kerning(1)
                    DatePicker("", selection: $meal.endTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(width: 150)
                        .tint(Color("orange"))
                }
            }
            
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    meal.timeActivated = true
                }
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color("orange"))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(Color("background"))
    }
}

// MARK: - Helpers (لم تتغير)
struct IdentifiableIndex: Identifiable {
    let value: Int
    var id: Int { value }
}

func makeTime(hour: Int) -> Date {
    Calendar.current.date(bySettingHour: min(hour, 23), minute: 0, second: 0, of: Date()) ?? Date()
}

func formatTime(_ date: Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "h:mm a"
    return f.string(from: date)
}

#Preview {
    SetYourPlanView(onDone: {})
}
