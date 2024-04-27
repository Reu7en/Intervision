//
//  CountdownTimerView.swift
//  Intervision
//
//  Created by Reuben on 27/04/2024.
//

import SwiftUI

struct CountdownTimerView: View {
    
    @StateObject var testingViewModel: TestingViewModel
    
    var body: some View {
        Text("\(testingViewModel.countdown)")
            .font(.largeTitle)
            .onAppear {
                testingViewModel.startCountdown()
            }
    }
}

#Preview {
    CountdownTimerView(testingViewModel: TestingViewModel())
}
