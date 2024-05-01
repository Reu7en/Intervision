//
//  NextQuestionButton.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct NextQuestionButton: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    @State private var showPracticeAlert: Bool = false
    
    var body: some View {
        if testingViewModel.isLastQuestion {
            Button {
                if testingViewModel.practice {
                    showPracticeAlert = true
                } else {
                    testingViewModel.goToResults()
                }
            } label: {
                Image(systemName: "flag.checkered")
                    .font(.title)
                    .padding()
            }
            .alert("Would you like to complete some more practice questions?", isPresented: $showPracticeAlert) {
                Button {
                    testingViewModel.practice = true
                    
                    testingViewModel.startTests()
                } label: {
                    Text("Yes")
                }
                
                Button {
                    testingViewModel.practice = false
                    
                    testingViewModel.startTests()
                } label: {
                    Text("No")
                }
            }
        } else {
            Button {
                testingViewModel.goToNextQuestion()
            } label: {
                Image(systemName: "arrow.right")
                    .font(.title)
                    .padding()
            }
        }
    }
}

#Preview {
    NextQuestionButton(testingViewModel: TestingViewModel())
}
