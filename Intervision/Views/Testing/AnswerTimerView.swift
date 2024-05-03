//
//  AnswerTimerView.swift
//  Intervision
//
//  Created by Reuben on 01/05/2024.
//

import SwiftUI

struct AnswerTimerView: View {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        GeometryReader { geometry in
            
            let cornerRadius = screenSizeViewModel.getEquivalentValue(10)
            
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(Color(red: 2 * testingViewModel.answerProgress, green: 2 * (1 - testingViewModel.answerProgress), blue: 0))
                    .offset(x: geometry.size.width * -testingViewModel.answerProgress)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
        }
    }
}

#Preview {
    AnswerTimerView(testingViewModel: TestingViewModel())
        .environmentObject(ScreenSizeViewModel())
}
