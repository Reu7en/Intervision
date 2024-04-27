//
//  RollThreeNoteOuterIntervalIdentificationWithInvertedLinesView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollThreeNoteOuterIntervalIdentificationWithInvertedLinesView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollThreeNoteOuterIntervalIdentificationWithInvertedLines")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollThreeNoteOuterIntervalIdentificationWithInvertedLinesView(testingViewModel: TestingViewModel())
}
