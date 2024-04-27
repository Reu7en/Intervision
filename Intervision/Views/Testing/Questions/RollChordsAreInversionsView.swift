//
//  RollChordsAreInversionsView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollChordsAreInversionsView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollChordsAreInversions")
                .font(.title)
            
            Text("\(String(describing: testingViewModel.testSession?.questions[testingViewModel.currentQuestion]))")
                .font(.title)
            
            Text("Are these two chords inversions of each other?")
                .font(.title2)
            
            Text("\(testingViewModel.currentQuestion + 1)/\(testingViewModel.questionCount)")
                .font(.title3)
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollChordsAreInversionsView(testingViewModel: TestingViewModel())
}
