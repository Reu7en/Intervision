//
//  RollThreeNoteOuterIntervalIdentificationView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollThreeNoteOuterIntervalIdentificationView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollThreeNoteOuterIntervalIdentification")
                .font(.title)
            
            Text("\(String(describing: testingViewModel.testSession?.questions[testingViewModel.currentQuestion]))")
                .font(.title)
            
            Text("Identify the interval between the lowest note and the highest note.")
                .font(.title2)
            
            Text("\(testingViewModel.currentQuestion + 1)/\(testingViewModel.questionCount)")
                .font(.title3)
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollThreeNoteOuterIntervalIdentificationView(testingViewModel: TestingViewModel())
}
