//
//  CountdownTimerView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct CountdownTimerView: View {
    
    @EnvironmentObject var screenSizeViewModel: DynamicSizingViewModel
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        let viewSize = screenSizeViewModel.viewSize
        
        ZStack {
            Circle()
                .stroke(lineWidth: screenSizeViewModel.getEquivalentValue(50))
                .opacity(0.3)
                .foregroundColor(Color.gray)
            
            Circle()
                .trim(from: 0, to: testingViewModel.progress)
                .stroke(style: StrokeStyle(lineWidth: screenSizeViewModel.getEquivalentValue(50), lineCap: .round))
                .foregroundStyle(Color(red: 2 * (1 - testingViewModel.progress), green: 2 * testingViewModel.progress, blue: 0))
                .rotationEffect(Angle(degrees: -90))
            
            if testingViewModel.countdown == 0 {
                Image(systemName: "play.fill")
                    .dynamicFont(.title)
                    .fontWeight(.semibold)
            } else {
                Text("\(testingViewModel.countdown)")
                    .dynamicFont(.title)
                    .fontWeight(.semibold)
            }
        }
        .frame(width: viewSize.width / 2, height: viewSize.height / 2)
        .onAppear {
            testingViewModel.startCountdown()
        }
        
        VStack {
            Spacer()
                .frame(height: viewSize.height / 1.35)
            
            if let session = testingViewModel.testSession, testingViewModel.countdown != 0 {
                let currentQuestionType = session.questions[testingViewModel.currentQuestionIndex].type
                
                Text("\(testingViewModel.practice ? "Practice Question" : "Question \(testingViewModel.currentQuestionIndex + 1)/\(40)")")
                    .dynamicFont(.title)
                    .fontWeight(.semibold)
                
                ForEach(currentQuestionType.description.filter( { $0 != "" } ), id: \.self) { description in
                    Text(description)
                        .dynamicFont(.title2)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    CountdownTimerView(testingViewModel: TestingViewModel())
        .environmentObject(DynamicSizingViewModel())
}
