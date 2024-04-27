//
//  ScoreThreeNoteOuterIntervalIdentificationView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct ScoreThreeNoteOuterIntervalIdentificationView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("ScoreThreeNoteOuterIntervalIdentification")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    ScoreThreeNoteOuterIntervalIdentificationView(testingViewModel: TestingViewModel())
}
