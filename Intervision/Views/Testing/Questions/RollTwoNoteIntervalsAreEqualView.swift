//
//  RollTwoNoteIntervalsAreEqualView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollTwoNoteIntervalsAreEqualView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollTwoNoteIntervalsAreEqual")
                .font(.title)
            
            Text("\(String(describing: testingViewModel.testSession?.questions[testingViewModel.currentQuestion]))")
                .font(.title)
            
            Text("Do these two chords contain the same interval?")
                .font(.title2)
            
            Text("\(testingViewModel.currentQuestion + 1)/\(testingViewModel.questionCount)")
                .font(.title3)
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollTwoNoteIntervalsAreEqualView(testingViewModel: TestingViewModel())
}
