//
//  RollThreeNoteInnerIntervalsIdentificationView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollThreeNoteInnerIntervalsIdentificationView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollThreeNoteInnerIntervalsIdentification")
                .font(.title)
            
            Text("\(String(describing: testingViewModel.testSession?.questions[testingViewModel.currentQuestion]))")
                .font(.title)
            
            Text("Identify the intervals between the following:\n1. The lowest note and the middle note.\n2. The middle note and the highest note.")
                .font(.title2)
            
            Text("\(testingViewModel.currentQuestion + 1)/\(testingViewModel.questionCount)")
                .font(.title3)
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollThreeNoteInnerIntervalsIdentificationView(testingViewModel: TestingViewModel())
}
