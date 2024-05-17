//
//  PageView.swift
//  Intervision
//
//  Created by Reuben on 06/02/2024.
//

import SwiftUI

struct PageView: View {
    
    @EnvironmentObject var screenSizeViewModel: DynamicSizingViewModel
    
    @Binding var zoomLevel: CGFloat
    
    let geometry: GeometryProxy
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
                            .dynamicFont(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.black)
                        
                        Text("\(scoreComposer)")
                            .dynamicFont(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.black)
                    }
                }
                
                ForEach(0..<bars.count, id: \.self) { lineIndex in
                    let pageWidth = width * 0.9
                    
                    HStack(spacing: 0) {
                        ForEach(0..<bars[lineIndex].count, id: \.self) { barIndex in
                            let bar = bars[lineIndex][barIndex]
                            
                            if bar.5 {
                                Text("\(bar.6)")
                                    .dynamicFont(12)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.black)
                                    .dynamicPadding(.horizontal)
                                    .frame(width: pageWidth / 10)
                            }
                            
                            BarView(
                                barViewModel: BarViewModel(
                                    bar: bar.0,
                                    gaps: 4,
                                    ledgerLines: 5,
                                    showClef: bar.2,
                                    showKey: bar.3,
                                    showTime: bar.4,
                                    showName: bar.5,
                                    partName: bar.6
                                )
                            )
                            .overlay(alignment: .topLeading) {
                                if bar.1 != -1 {
                                    Text("\(bar.1)")
                                        .foregroundStyle(Color.black)
                                        .dynamicFont(12)
                                }
                            }
                            .environmentObject(screenSizeViewModel)
                        }
                    }
                    .frame(width: pageWidth)
                    .frame(maxHeight: height / 5)
                }
                
                Spacer()
            }
            .frame(height: height * 0.9)
        }
        .frame(width: width, height: height)
        .dynamicPadding()
    }
}

#Preview {
    GeometryReader { geometry in
        PageView(zoomLevel: Binding.constant(1.0), geometry: geometry, bars: [], showScoreInformation: false, scoreTitle: "", scoreComposer: "")
            .environmentObject(DynamicSizingViewModel())
    }
}
