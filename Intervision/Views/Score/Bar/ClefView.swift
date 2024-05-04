//
//  ClefView.swift
//  Intervision
//
//  Created by Reuben on 20/02/2024.
//

import SwiftUI

struct ClefView: View {
    
    let clef: Bar.Clef
    let gapHeight: CGFloat
    
    var body: some View {
        ZStack {
            switch clef {
            case .Treble:
                ZStack {
                    Image("ClefTreble")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                        .frame(height: gapHeight * 8)
                }
            case .Soprano:
                ZStack {
                    Image("ClefSATB")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                        .frame(height: gapHeight * 4)
                        .offset(y: gapHeight * 2)
                }
            case .Alto:
                ZStack {
                    Image("ClefSATB")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                        .frame(height: gapHeight * 4)
                }
            case .Tenor:
                ZStack {
                    Image("ClefSATB")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                        .frame(height: gapHeight * 4)
                        .offset(y: -gapHeight)
                }
            case .Bass:
                ZStack {
                    Image("ClefBass")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                        .frame(height: gapHeight * 3.5)
                        .offset(y: -gapHeight / 4)
                }
            case .Neutral:
                ZStack {
                    Image("ClefNeutral")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                        .frame(height: gapHeight * 4)
                }
            }
        }
    }
}

#Preview {
    ClefView(clef: .Treble, gapHeight: 50)
}
