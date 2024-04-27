//
//  RollThreeNoteInnerIntervalsIdentificationWithInvertedLinesView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollThreeNoteInnerIntervalsIdentificationWithInvertedLinesView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollThreeNoteInnerIntervalsIdentificationWithInvertedLines")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollThreeNoteInnerIntervalsIdentificationWithInvertedLinesView(testingViewModel: TestingViewModel())
}
