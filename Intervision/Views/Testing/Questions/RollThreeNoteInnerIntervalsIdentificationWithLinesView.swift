//
//  RollThreeNoteInnerIntervalsIdentificationWithLinesView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollThreeNoteInnerIntervalsIdentificationWithLinesView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollThreeNoteInnerIntervalsIdentificationWithLines")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollThreeNoteInnerIntervalsIdentificationWithLinesView(testingViewModel: TestingViewModel())
}
