//
//  BothThreeNoteChordsAreEqualNoLinesView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct BothThreeNoteChordsAreEqualNoLinesView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("BothThreeNoteChordsAreEqualNoLines")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    BothThreeNoteChordsAreEqualNoLinesView(testingViewModel: TestingViewModel())
}
