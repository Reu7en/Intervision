//
//  RollThreeNoteInnerIntervalsIdentificationNoLinesView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollThreeNoteInnerIntervalsIdentificationNoLinesView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollThreeNoteInnerIntervalsIdentificationNoLines")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollThreeNoteInnerIntervalsIdentificationNoLinesView(testingViewModel: TestingViewModel())
}
