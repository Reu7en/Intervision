//
//  RestView.swift
//  Intervision
//
//  Created by Reuben on 16/02/2024.
//

import SwiftUI

struct RestView: View {
    
    let size: CGFloat
    let duration: Note.Duration
    let isDotted: Bool
    let scale: CGFloat
    
    var body: some View {
        ZStack {
            switch duration {
            case .bar, .breve, .whole:
                ZStack {
                    Image("RestWhole")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                    
                    if isDotted {
                        HStack {
                            Spacer()
                            
                            Circle()
                                .fill(Color.black)
                                .frame(width: size / 10)
                                .padding(10 * scale)
                        }
                    }
                }
                .offset(y: -size / 5)
                .scaleEffect(2.0)
            case .half:
                ZStack {
                    Image("RestHalf")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                    
                    if isDotted {
                        HStack {
                            Spacer()
                            
                            Circle()
                                .fill(Color.black)
                                .frame(width: size / 10)
                                .padding(10 * scale)
                        }
                    }
                }
                .offset(y: -size / 5)
                .scaleEffect(2.0)
            case .quarter:
                ZStack {
                    Image("RestQuarter")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                    
                    if isDotted {
                        HStack {
                            Spacer()
                            Spacer()
                            
                            Circle()
                                .fill(Color.black)
                                .frame(width: size / 10)
                                .padding(10 * scale)
                            
                            Spacer()
                        }
                    }
                }
            case .eighth:
                ZStack {
                    Image("RestEighth")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                    
                    if isDotted {
                        HStack {
                            Spacer()
                            Spacer()
                            Spacer()
                            
                            Circle()
                                .fill(Color.black)
                                .frame(width: size / 10)
                                .padding(10 * scale)
                            
                            Spacer()
                        }
                    }
                }
            case .sixteenth:
                ZStack {
                    Image("RestSixteenth")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                    
                    if isDotted {
                        HStack {
                            Spacer()
                            Spacer()
                            Spacer()
                            
                            Circle()
                                .fill(Color.black)
                                .frame(width: size / 10)
                                .padding(10 * scale)
                            
                            Spacer()
                        }
                    }
                }
            case .thirtySecond:
                ZStack {
                    Image("RestThirtySecond")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                    
                    if isDotted {
                        HStack {
                            Spacer()
                            Spacer()
                            
                            Circle()
                                .fill(Color.black)
                                .frame(width: size / 10)
                                .padding(10 * scale)
                            
                            Spacer()
                        }
                    }
                }
            case .sixtyFourth:
                ZStack {
                    Image("RestSixtyFourth")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                    
                    if isDotted {
                        HStack {
                            Spacer()
                            Spacer()
                            
                            Circle()
                                .fill(Color.black)
                                .frame(width: size / 10)
                                .padding(10 * scale)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(width: size)
        .scaleEffect(0.85)
    }
}

#Preview {
    RestView(size: 500, duration: Note.Duration.whole, isDotted: true, scale: 1.0)
}
