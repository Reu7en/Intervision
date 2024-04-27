//
//  BothTwoNoteChordsAreEqualNoLinesView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct BothTwoNoteChordsAreEqualNoLinesView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("BothTwoNoteChordsAreEqualNoLines")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    BothTwoNoteChordsAreEqualNoLinesView(testingViewModel: TestingViewModel())
}
