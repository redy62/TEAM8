//
//  SplashView.swift
//  Mealo
//
//  Created by ريناد محمد حملي on 02/12/1447 AH.
//

import SwiftUI

struct SplashView: View {
    var onGetStarted: () -> Void
    
    @State private var characterOffset: CGFloat = 300
    @State private var characterOpacity: Double = 0

    var body: some View {
        ZStack {
            Color("background")

            VStack(spacing: 0) {
                Spacer()

                Image("ch1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .offset(y: characterOffset)
                    .opacity(characterOpacity)

                Spacer().frame(height: 32)

                Text("Mealo")
                    .font(.custom("Georgia", size: 42))
                    .foregroundColor(Color("orange"))
                    .fontWeight(.bold)

                Spacer().frame(height: 12)

                VStack(spacing: 4) {
                    Text("Skipping meals isn't a choice, it's a habit")
                    Text("Let's build a better one.")
                }
                .font(.custom("Georgia", size: 14))
                .foregroundColor(Color("orange").opacity(0.7))
                .multilineTextAlignment(.center)

                Spacer()

                Text("No pressure, just progress!")
                    .font(.system(size: 13))
                    .foregroundColor(Color("orange").opacity(0.5))

                Spacer().frame(height: 48)
            }
            .padding(.horizontal, 32)
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // يدخل من تحت بسرعة
            withAnimation(.easeOut(duration: 0.4)) {
                characterOffset = 0
                characterOpacity = 1
            }
            
            // نطة أولى
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.2)) {
                    characterOffset = -30
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        characterOffset = 0
                    }
                }
            }
            
            // نطة ثانية أصغر
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeOut(duration: 0.15)) {
                    characterOffset = -15
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
                    withAnimation(.easeIn(duration: 0.15)) {
                        characterOffset = 0
                    }
                }
            }
            
            // auto-dismiss بعد 2.5 ثانية
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onGetStarted()
            }
        }
    }
}

#Preview {
    SplashView(onGetStarted: {})
}
