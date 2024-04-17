//
//  PageView.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import SwiftUI

struct PageView: View {
    
    let geometry: GeometryProxy
    @Binding var zoomLevel: CGFloat
    
    let bars: [[(Bar, Int, Bool, Bool, Bool, Bool, String)]]
    let showScoreInformation: Bool
    let scoreTitle: String
    let scoreComposer: String
    
    var body: some View {
        
        let width = geometry.size.height * ScoreViewModel.pageAspectRatio * zoomLevel
        let height = geometry.size.height * zoomLevel
        
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
            
            VStack(spacing: 0) {
                if showScoreInformation {
                    VStack {
                        Text("\(scoreTitle)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.black)
                        
                        Text("\(scoreComposer)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.black)
                    }
                }
                
                ForEach(0..<bars.count, id: \.self) { lineIndex in
                    HStack(spacing: 0) {
                        ForEach(0..<bars[lineIndex].count, id: \.self) { barIndex in
                            let bar = bars[lineIndex][barIndex]
                            
                            BarView(
                                barViewModel: BarViewModel(
                                    bar: bar.0,
                                    gaps: 4,
                                    ledgerLines: 4,
                                    showClef: bar.2,
                                    showKey: bar.3,
                                    showTime: bar.4,
                                    showName: bar.5,
                                    partName: bar.6,
                                    pageWidth: width
                                )
                            )
                            .overlay(alignment: .topLeading) {
                                if bar.1 != -1 {
                                    Text("\(bar.1)")
                                        .foregroundStyle(Color.black)
                                }
                            }
                        }
                    }
                    .frame(width: width * 0.9)
                }
            }
            .frame(height: height * 0.9)
        }
        .frame(width: width, height: height)
        .padding()
    }
}

#Preview {
    GeometryReader { geometry in
        PageView(geometry: geometry, zoomLevel: Binding.constant(1.0), bars: [], showScoreInformation: false, scoreTitle: "", scoreComposer: "")
    }
}
