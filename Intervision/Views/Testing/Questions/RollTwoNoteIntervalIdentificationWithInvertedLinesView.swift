//
//  RollTwoNoteIntervalIdentificationWithInvertedLinesView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollTwoNoteIntervalIdentificationWithInvertedLinesView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollTwoNoteIntervalIdentificationWithInvertedLines")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollTwoNoteIntervalIdentificationWithInvertedLinesView(testingViewModel: TestingViewModel())
}
