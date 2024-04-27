//
//  RollThreeNoteOuterIntervalIdentificationNoLinesView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollThreeNoteOuterIntervalIdentificationNoLinesView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollThreeNoteOuterIntervalIdentificationNoLines")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollThreeNoteOuterIntervalIdentificationNoLinesView(testingViewModel: TestingViewModel())
}
