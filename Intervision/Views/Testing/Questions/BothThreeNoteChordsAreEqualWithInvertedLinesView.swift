//
//  BothThreeNoteChordsAreEqualWithInvertedLinesView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct BothThreeNoteChordsAreEqualWithInvertedLinesView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("BothThreeNoteChordsAreEqualWithInvertedLines")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    BothThreeNoteChordsAreEqualWithInvertedLinesView(testingViewModel: TestingViewModel())
}
