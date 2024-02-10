//
//  MainWindowView.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import SwiftUI

struct MainWindowView: View {
    
    @StateObject private var scoreViewModel = ScoreViewModel()
    
    var body: some View {
        ScoreView()
            .environmentObject(scoreViewModel)
            .onAppear {
                TestLoad.testLoad()
            }
    }
}

#Preview {
    MainWindowView()
}
