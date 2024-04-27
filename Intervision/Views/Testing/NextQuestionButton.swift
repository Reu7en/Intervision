//
//  NextQuestionButton.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct NextQuestionButton: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        if testingViewModel.isLastQuestion {
            Button {
                testingViewModel.goToResults()
            } label: {
                Image(systemName: "flag.checkered")
                    .font(.title)
                    .padding()
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
