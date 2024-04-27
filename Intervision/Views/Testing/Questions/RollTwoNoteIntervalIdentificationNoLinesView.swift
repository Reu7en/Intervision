//
//  RollTwoNoteIntervalIdentificationNoLinesView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollTwoNoteIntervalIdentificationNoLinesView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollTwoNoteIntervalIdentificationNoLines")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollTwoNoteIntervalIdentificationNoLinesView(testingViewModel: TestingViewModel())
}
