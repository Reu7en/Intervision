//
//  NextQuestionButton.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct NextQuestionButton: View {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    @StateObject var testingViewModel: TestingViewModel
    
    @State private var showPracticeAlert: Bool = false
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.5)) {
                testingViewModel.questionVisible = false
            }
            
            if testingViewModel.isLastQuestion {
                if testingViewModel.practice {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        testingViewModel.startTests()
                    }
                } else {
                    testingViewModel.goToResults()
                }
            } else {
                testingViewModel.goToNextQuestion()
            }
        } label: {
            Image(systemName: testingViewModel.isLastQuestion && !testingViewModel.practice ? "flag.checkered" : "arrow.right")
                .equivalentFont(.largeTitle)
                .equivalentPadding()
                .equivalentPadding(.horizontal, padding: 50)
        }
        .buttonStyle(BorderedButtonStyle())
    }
}

#Preview {
    NextQuestionButton(testingViewModel: TestingViewModel())
        .environmentObject(ScreenSizeViewModel())
}
