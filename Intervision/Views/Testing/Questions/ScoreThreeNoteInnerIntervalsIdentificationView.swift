//
//  ScoreThreeNoteInnerIntervalsIdentificationView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct ScoreThreeNoteInnerIntervalsIdentificationView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("ScoreThreeNoteInnerIntervalsIdentification")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    ScoreThreeNoteInnerIntervalsIdentificationView(testingViewModel: TestingViewModel())
}
