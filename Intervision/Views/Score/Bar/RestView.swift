//
//  RestView.swift
//  Intervision
//
//  Created by Reuben on 16/02/2024.
//

import SwiftUI

struct RestView: View {
    
    let gapHeight: CGFloat
    let duration: Note.Duration
    let isDotted: Bool
    
    var body: some View {
        switch duration {
        case .bar, .breve, .whole:
            ZStack {
                Image("RestWhole")
                    .interpolation(.high)
                    .resizable()
                    .scaledToFit()
                
                if isDotted {
                    Circle()
                        .fill(Color.black)
                        .frame(height: gapHeight * 0.375)
                        .offset(x: gapHeight * 2)
                }
            }
            .frame(height: gapHeight * 0.75)
            .offset(y: -gapHeight / 1.5)
        case .half:
            ZStack {
                Image("RestHalf")
                    .interpolation(.high)
                    .resizable()
                    .scaledToFit()
                
                if isDotted {
                    Circle()
                        .fill(Color.black)
                        .frame(height: gapHeight * 0.375)
                        .offset(x: gapHeight * 2)
                }
            }
            .frame(height: gapHeight * 0.75)
            .offset(y: -gapHeight / 2.75)
        case .quarter:
            ZStack {
                Image("RestQuarter")
                    .interpolation(.high)
                    .resizable()
                    .scaledToFit()
                
                if isDotted {
                    Circle()
                        .fill(Color.black)
                        .frame(height: gapHeight * 0.375)
                        .offset(x: gapHeight, y: -gapHeight / 2)
                }
            }
            .frame(height: gapHeight * 3)
        case .eighth:
            ZStack {
                Image("RestEighth")
                    .interpolation(.high)
                    .resizable()
                    .scaledToFit()
                
                if isDotted {
                    Circle()
                        .fill(Color.black)
                        .frame(height: gapHeight * 0.375)
                        .offset(x: gapHeight, y: -gapHeight / 2)
                }
            }
            .frame(height: gapHeight * 2)
        case .sixteenth:
            ZStack {
                Image("RestSixteenth")
                    .interpolation(.high)
                    .resizable()
                    .scaledToFit()
                
                if isDotted {
                    Circle()
                        .fill(Color.black)
                        .frame(height: gapHeight * 0.375)
                        .offset(x: gapHeight, y: -gapHeight)
                }
            }
            .offset(y: gapHeight / 2)
            .frame(height: gapHeight * 3)
        case .thirtySecond:
            ZStack {
                Image("RestThirtySecond")
                    .interpolation(.high)
                    .resizable()
                    .scaledToFit()
                
                if isDotted {
                    Circle()
                        .fill(Color.black)
                        .frame(height: gapHeight * 0.375)
                        .offset(x: gapHeight, y: -gapHeight / 1.5)
                }
            }
            .frame(height: gapHeight * 4)
        case .sixtyFourth:
            ZStack {
                Image("RestSixtyFourth")
                    .interpolation(.high)
                    .resizable()
                    .scaledToFit()
                
                if isDotted {
                    Circle()
                        .fill(Color.black)
                        .frame(height: gapHeight * 0.375)
                        .offset(x: gapHeight, y: -gapHeight / 1.5)
                }
            }
            .frame(height: gapHeight * 4)
        }
    }
}

#Preview {
    RestView(gapHeight: 500, duration: Note.Duration.half, isDotted: true)
}
