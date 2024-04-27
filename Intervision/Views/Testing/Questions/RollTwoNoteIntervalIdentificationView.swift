//
//  RollTwoNoteIntervalIdentificationView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollTwoNoteIntervalIdentificationView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollTwoNoteIntervalIdentification")
                .font(.title)
            
            Text("\(String(describing: testingViewModel.testSession?.questions[testingViewModel.currentQuestion]))")
                .font(.title)
            
            Text("Identify the interval formed by these two notes.")
                .font(.title2)
            
            Text("\(testingViewModel.currentQuestion + 1)/\(testingViewModel.questionCount)")
                .font(.title3)
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollTwoNoteIntervalIdentificationView(testingViewModel: TestingViewModel())
}
