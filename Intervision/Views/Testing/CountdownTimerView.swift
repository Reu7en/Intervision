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
        GeometryReader { geometry in
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
            .frame(width: geometry.size.width / 3, height: geometry.size.height / 3)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .onAppear {
                testingViewModel.startCountdown()
            }
            
            VStack {
                Spacer()
                    .frame(height: geometry.size.height / 1.5)
                
                if let session = testingViewModel.testSession, testingViewModel.countdown != 0 {
                    let currentQuestionType = session.questions[testingViewModel.currentQuestionIndex].type
                    
                    Text("\(testingViewModel.practice ? "Practice Question" : "Question \(testingViewModel.currentQuestionIndex + 1)/\(30)")")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    ForEach(currentQuestionType.description.filter( { $0 != "" } ), id: \.self) { description in
                        Text(description)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

#Preview {
    CountdownTimerView(testingViewModel: TestingViewModel())
}
