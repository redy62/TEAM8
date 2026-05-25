//
//  TEAM8App.swift
//  TEAM8
//
//  Created by ريناد محمد حملي on 02/12/1447 AH.
//

import SwiftUI

@main
struct MealoApp: App {
    @State private var showSplash = true
    @State private var onboardingDone = false

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView {
                    withAnimation {
                        showSplash = false
                    }
                }
            } else if !onboardingDone {
                SetYourPlanView {
                    withAnimation {
                        onboardingDone = true
                    }
                }
            } else {
                // الصفحة الرئيسية بعد الأونبوردينج
                PromiseView(onDone: {
                    // إذا سويت الصفحة الرئيسية الفعلية للتطبيق مستقبلاً، بتناديها هنا
                    print("انتهى الوعد!")
                })
            }
        }
    }
}
