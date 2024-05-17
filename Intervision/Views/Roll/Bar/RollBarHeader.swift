//
//  RollBarHeader.swift
//  Intervision
//
//  Created by Reuben on 01/03/2024.
//

import SwiftUI

struct RollBarHeader: View {
    
    @EnvironmentObject var screenSizeViewModel: DynamicSizingViewModel
    
    let barIndex: Int
    let headerHeight: CGFloat
    let geometry: GeometryProxy
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: headerHeight)
            .overlay {
                HStack(spacing: 0) {
                    Text("\(barIndex + 1)")
                        .dynamicFont(16)
                        .foregroundStyle(Color.gray)
                        .padding(.horizontal, geometry.size.width / 200)
                    
                    Spacer()
                }
            }
    }
}

#Preview {
    GeometryReader { geometry in
        RollBarHeader(barIndex: 0, headerHeight: 0, geometry: geometry)
            .environmentObject(DynamicSizingViewModel())
    }
}
