//
//  CustomizeMealsView.swift
//  Mealo
//
//  Created by ريناد محمد حملي on 05/12/1447 AH.
//

import SwiftUI

// MARK: - PAGE 2: Customize Meals View
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
                      .font(.custom("Georgia", size: 30))
                      .foregroundColor(Color("orange"))
                      .padding(.bottom, 4)
                  
                  Text("Set the icons and times for your daily meals.")
                      .font(.system(size: 12))
                      .foregroundColor(Color("brown").opacity(0.45))
                      .padding(.bottom, 24)
                  
                  VStack(spacing: 10) {
                      ForEach(meals.indices, id: \.self) { i in
                          MealBoxView(
                              meal: $meals[i],
                              onTimeTap: { activeMealIndex = i }
                          )
                      }
                  }
                  .padding(.bottom, 32)
                  
                  Button(action: onDone) {
                      Text("Start my journey →")
                          .font(.system(size: 15, weight: .medium))
                          .foregroundColor(.white)
                          .frame(maxWidth: .infinity)
                          .padding(.vertical, 14)
                          .background(Color("orange"))
                          .clipShape(Capsule())
                  }
                  
                  HStack(spacing: 6) {
                      Image("Point2")
                      Image("Point1")
                      Image("Point2")
                  }
                  .frame(maxWidth: .infinity, alignment: .center)
                  .padding(.top, 20)
                  .padding(.bottom, 40)
              }
              .padding(.horizontal, 24)
              .padding(.top, 56)
              .padding(.bottom, 40)
          }
      }
      .sheet(item: Binding(
          get: { activeMealIndex.map { IdentifiableIndex(value: $0) } },
          set: { activeMealIndex = $0?.value }
      )) { idx in
          TimePicker(meal: $meals[idx.value])
              .presentationDetents([.height(280)])
              .presentationDragIndicator(.visible)
              .presentationBackground(Color("background"))
      }
  }
}

// MARK: - Time Diff Helper
func timeDiff(_ start: Date, _ end: Date) -> String {
   let diff = Int(end.timeIntervalSince(start) / 60)
   let absDiff = abs(diff)
   if absDiff < 60 {
       return "\(absDiff)m"
   } else if absDiff % 60 == 0 {
       return "\(absDiff / 60)h"
   } else {
       return "\(absDiff / 60)h\(absDiff % 60)m"
   }
}

// MARK: - MealBoxView
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
                  Text(timeDiff(meal.startTime, meal.endTime))
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
      }
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

// MARK: - TimePicker Sheet
struct TimePicker: View {
  @Binding var meal: MealEntry
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
      VStack(spacing: 20) {
          Text("Set reminder")
              .font(.custom("Georgia", size: 20))
              .foregroundColor(Color("brown"))
              .padding(.top, 24)
          
          HStack(spacing: 32) {
              VStack(spacing: 8) {
                  Text("START")
                      .font(.system(size: 15))
                      .foregroundColor(Color("orange"))
                      .kerning(1)
                  DatePicker("", selection: $meal.startTime, displayedComponents: .hourAndMinute)
                      .datePickerStyle(.compact)
                      .labelsHidden()
                      .tint(Color("orange"))
              }
              
              Text("→")
                  .foregroundColor(Color("orange").opacity(0.4))
              
              VStack(spacing: 8) {
                  Text("END")
                      .font(.system(size: 15))
                      .foregroundColor(Color("orange"))
                      .kerning(1)
                  DatePicker("", selection: $meal.endTime, displayedComponents: .hourAndMinute)
                      .datePickerStyle(.compact)
                      .labelsHidden()
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
          .padding(.bottom, 20)
      }
      .background(Color("background"))
  }
}

#Preview {
  CustomizeMealsView(meals: .constant([
      MealEntry(icon: "🌙", label: "Night snack", startTime: makeTime(hour: 21), endTime: makeTime(hour: 22)),
      MealEntry(icon: "☀️", label: "Midday meal", startTime: makeTime(hour: 12), endTime: makeTime(hour: 13))
  ]), onDone: {})
}
