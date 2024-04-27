//
//  ScoreChordsAreInversionsView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct ScoreChordsAreInversionsView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        VStack {
            Text("ScoreChordsAreInversions")
            
            NextQuestionButton(testingViewModel: testingViewModel)
        }
    }
}

#Preview {
    ScoreChordsAreInversionsView(testingViewModel: TestingViewModel())
}
