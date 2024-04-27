//
//  RollChordsAreInversionsWithInvertedLinesView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollChordsAreInversionsWithInvertedLinesView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollChordsAreInversionsWithInvertedLines")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollChordsAreInversionsWithInvertedLinesView(testingViewModel: TestingViewModel())
}
