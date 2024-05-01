//
//  CountdownTimerView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct CountdownTimerView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(Color.gray)

            Circle()
                .trim(from: 0, to: testingViewModel.progress)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .foregroundStyle(Color(red: 2 * (1 - testingViewModel.progress), green: 2 * testingViewModel.progress, blue: 0))
                .rotationEffect(Angle(degrees: -90))

            if testingViewModel.countdown == 0 {
                Image(systemName: "play.fill")
                    .font(.largeTitle)
            } else {
                Text("\(testingViewModel.countdown)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .onAppear {
            testingViewModel.startCountdown()
        }
    }
}

#Preview {
    CountdownTimerView(testingViewModel: TestingViewModel())
}
