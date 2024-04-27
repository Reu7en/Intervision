//
//  ScoreTwoNoteIntervalIdentificationView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct ScoreTwoNoteIntervalIdentificationView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("ScoreTwoNoteIntervalIdentification")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    ScoreTwoNoteIntervalIdentificationView(testingViewModel: TestingViewModel())
}
