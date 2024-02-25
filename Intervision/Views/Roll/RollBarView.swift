//
//  RollBarView.swift
//  Intervision
//
//  Created by Reuben on 24/02/2024.
//

import SwiftUI

struct RollBarView: View {
    
    @StateObject var rollBarViewModel: RollBarViewModel
    let geometry: GeometryProxy
    
    var body: some View {
        Color.clear
    }
}

#Preview {
    GeometryReader { geometry in
        RollBarView(rollBarViewModel: RollBarViewModel(bars: [], octaves: 9), geometry: geometry)
    }
}
