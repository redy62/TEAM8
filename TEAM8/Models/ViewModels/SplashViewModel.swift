//
//  SplashView.swift
//  Mealo
//
//  Created by ريناد محمد حملي on 02/12/1447 AH.
//

import SwiftUI

struct SplashView: View {
    var onGetStarted: () -> Void

    var body: some View {
        ZStack {
            Color("background")

            VStack(spacing: 0) {
                Spacer()

                Image("ch")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)

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

                VStack(spacing: 24) {
                    Text("No pressure, just progress!")
                        .font(.system(size: 13))
                        .foregroundColor(Color("orange").opacity(0.5))

                    Button(action: onGetStarted) {
                        Text("Let's get started")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 14)
                            .background(Color("orange"))
                            .clipShape(Capsule())
                    }
                }

                Spacer().frame(height: 48)
            }
            .padding(.horizontal, 32)
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SplashView(onGetStarted: {})
}
