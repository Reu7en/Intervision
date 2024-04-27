//
//  RollTwoNoteIntervalIdentificationWithLinesView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollTwoNoteIntervalIdentificationWithLinesView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollTwoNoteIntervalIdentificationWithLines")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollTwoNoteIntervalIdentificationWithLinesView(testingViewModel: TestingViewModel())
}
