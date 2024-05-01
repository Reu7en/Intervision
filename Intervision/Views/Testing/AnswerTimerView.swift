//
//  AnswerTimerView.swift
//  Intervision
//
//  Created by Reuben on 01/05/2024.
//

import SwiftUI

struct AnswerTimerView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(red: 2 * testingViewModel.answerProgress, green: 2 * (1 - testingViewModel.answerProgress), blue: 0))
                    .offset(x: geometry.size.width * -testingViewModel.answerProgress)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

#Preview {
    AnswerTimerView(testingViewModel: TestingViewModel())
}
