//
//  BothTwoNoteChordsAreEqualWithInvertedLinesView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct BothTwoNoteChordsAreEqualWithInvertedLinesView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("BothTwoNoteChordsAreEqualWithInvertedLines")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    BothTwoNoteChordsAreEqualWithInvertedLinesView(testingViewModel: TestingViewModel())
}
