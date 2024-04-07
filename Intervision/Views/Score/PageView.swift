//
//  PageView.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import SwiftUI

struct PageView: View {
    
    @Binding var geometry: GeometryProxy
    @Binding var zoomLevel: CGFloat
    
    let bars: [[Bar]]
    let part: Part
    
    var body: some View {
        
        let width = geometry.size.height * ScoreViewModel.pageAspectRatio * zoomLevel
        let height = geometry.size.height * zoomLevel
        
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
            
            ScrollView {
                if let name = part.name {
                    Text("\(name)")
                        .font(.title)
                        .foregroundStyle(Color.black)
                }
                
                LazyVStack(spacing: 0) {
                    ForEach(0..<bars.count, id: \.self) { barIndex in
                        ForEach(0..<bars[barIndex].count, id: \.self) { voiceIndex in
                            BarView(
                                barViewModel: BarViewModel(
                                    bar: bars[barIndex][voiceIndex],
                                    gaps: 4,
                                    ledgerLines: 4,
                                    showClef: true,
                                    showKey: true,
                                    showTime: true
                                )
                            )
                            .frame(width: width * 0.9, height: height / 6)
                            .id(UUID())
                            .overlay(alignment: .topLeading) {
                                Text("\(barIndex + 1)")
                                    .foregroundStyle(Color.black)
                            }
                        }
                    }
                }
            }
        }
        .frame(width: width, height: height)
        .padding()
    }
}

#Preview {
    GeometryReader { geometry in
        PageView(geometry: Binding.constant(geometry), zoomLevel: Binding.constant(1.0), bars: [], part: Part(bars: []))
    }
}
