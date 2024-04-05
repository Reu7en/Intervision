//
//  TimeSignatureView.swift
//  Intervision
//
//  Created by Reuben on 21/02/2024.
//

import SwiftUI

struct TimeSignatureView: View {
    
    @State var doubleDigit: Bool = false
    
    let height: CGFloat
    let timeSignature: Bar.TimeSignature
    
    var body: some View {
        ZStack {
            switch timeSignature {
            case .common:
                Image("Common")
                    .interpolation(.high)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.5)
            case .cut:
                Image("Cut")
                    .interpolation(.high)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.5)
            case .custom(let beats, let noteValue):
                VStack(spacing: 0) {
                    switch beats {
                    case 1:
                        Image("1")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 2:
                        Image("2")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 3:
                        Image("3")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 4:
                        Image("4")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 5:
                        Image("5")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 6:
                        Image("6")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 7:
                        Image("7")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 8:
                        Image("8")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 9:
                        Image("9")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 10:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("0")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 11:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 12:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("2")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 13:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("3")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 14:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("4")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 15:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("5")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 16:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("6")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 17:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("7")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 18:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("8")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 19:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("9")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 20:
                        HStack(spacing: 0) {
                            Image("2")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("0")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 21:
                        HStack(spacing: 0) {
                            Image("2")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 22:
                        HStack(spacing: 0) {
                            Image("2")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("2")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 23:
                        HStack(spacing: 0) {
                            Image("2")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("3")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 24:
                        HStack(spacing: 0) {
                            Image("2")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("4")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    default:
                        Image("Common")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(0.5)
                    }
                    
                    switch noteValue {
                    case 1:
                        Image("1")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 2:
                        Image("2")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 3:
                        Image("3")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 4:
                        Image("4")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 5:
                        Image("5")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 6:
                        Image("6")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 7:
                        Image("7")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 8:
                        Image("8")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 9:
                        Image("9")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                    case 10:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("0")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 11:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 12:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("2")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 13:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("3")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 14:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("4")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 15:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("5")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 16:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("6")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 17:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("7")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 18:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("8")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 19:
                        HStack(spacing: 0) {
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("9")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 20:
                        HStack(spacing: 0) {
                            Image("2")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("0")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 21:
                        HStack(spacing: 0) {
                            Image("2")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("1")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 22:
                        HStack(spacing: 0) {
                            Image("2")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("2")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 23:
                        HStack(spacing: 0) {
                            Image("2")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("3")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    case 24:
                        HStack(spacing: 0) {
                            Image("2")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                            
                            Image("4")
                                .interpolation(.high)
                                .resizable()
                                .scaledToFit()
                        }
                        .onAppear {
                            doubleDigit = true
                        }
                    default:
                        Image("Common")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(0.5)
                    }
                }
            }
        }
        .frame(height: height)
    }
}

#Preview {
    TimeSignatureView(height: 100, timeSignature: .custom(beats: 12, noteValue: 8))
}
