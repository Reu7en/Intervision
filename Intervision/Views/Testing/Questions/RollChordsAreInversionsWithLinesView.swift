//
//  RollChordsAreInversionsWithLinesView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct RollChordsAreInversionsWithLinesView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("RollChordsAreInversionsWithLines")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    RollChordsAreInversionsWithLinesView(testingViewModel: TestingViewModel())
}
