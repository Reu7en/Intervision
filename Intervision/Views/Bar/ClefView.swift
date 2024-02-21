//
//  ClefView.swift
//  Intervision
//
//  Created by Reuben on 20/02/2024.
//

import SwiftUI

struct ClefView: View {
    
    let width: CGFloat
    let height: CGFloat
    let clef: Bar.Clef
    
    var body: some View {
        ZStack {
            switch clef {
            case .Treble:
                ZStack {
                    Image("ClefTreble")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                }
            case .Soprano:
                ZStack {
                    Image("ClefSATB")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                }
            case .Alto:
                ZStack {
                    Image("ClefSATB")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                }
            case .Tenor:
                ZStack {
                    Image("ClefSATB")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                }
            case .Bass:
                ZStack {
                    Image("ClefBass")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.5)
                }
            case .Neutral:
                ZStack {
                    Image("ClefNeutral")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .frame(width: width, height: height)
    }
}

#Preview {
    ClefView(width: 50, height: 100, clef: .Treble)
}
