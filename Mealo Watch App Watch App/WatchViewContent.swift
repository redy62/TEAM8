//  WatchContentView.swift
//  Mealo
//
//  Created by Rahaf on 01/06/2026.


import SwiftUI

struct WatchContentView: View {
    var body: some View {
        TabView {
            WatchStateView()
            WatchLogFoodView()
            WatchStreakView()
            WatchAnalyticsView()
        }
        .tabViewStyle(.verticalPage)
    }
}

