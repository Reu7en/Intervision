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
    
    var body: some View {
        ZStack {
            switch duration {
            case .bar, .breve, .whole:
                ZStack {
                    Image("RestWhole")
                        .resizable()
                        .scaledToFit()
                    
                    if isDotted {
                        HStack {
                            Spacer()
                            
                            Circle()
                                .fill(Color.black)
                                .frame(width: size / 10)
                                .padding()
                        }
                    }
                }
            case .half:
                Image("RestHalf")
                    .resizable()
                    .scaledToFit()
                
                if isDotted {
                    HStack {
                        Spacer()
                        
                        Circle()
                            .fill(Color.black)
                            .frame(width: size / 10)
                            .padding()
                    }
                }
            case .quarter:
                Image("RestQuarter")
                    .resizable()
                    .scaledToFit()
                
                if isDotted {
                    HStack {
                        Spacer()
                        Spacer()
                        
                        Circle()
                            .fill(Color.black)
                            .frame(width: size / 10)
                            .padding()
                        
                        Spacer()
                    }
                }
            case .eighth:
                Image("RestEighth")
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
                            .padding()
                        
                        Spacer()
                    }
                }
            case .sixteenth:
                Image("RestSixteenth")
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
                            .padding()
                        
                        Spacer()
                    }
                }
            case .thirtySecond:
                Image("RestThirtySecond")
                    .resizable()
                    .scaledToFit()
                
                if isDotted {
                    HStack {
                        Spacer()
                        Spacer()
                        
                        Circle()
                            .fill(Color.black)
                            .frame(width: size / 10)
                            .padding()
                        
                        Spacer()
                    }
                }
            case .sixtyFourth:
                Image("RestSixtyFourth")
                    .resizable()
                    .scaledToFit()
                
                if isDotted {
                    HStack {
                        Spacer()
                        Spacer()
                        
                        Circle()
                            .fill(Color.black)
                            .frame(width: size / 10)
                            .padding()
                        
                        Spacer()
                    }
                }
            }
        }
        .frame(width: size)
        .scaleEffect(0.85)
    }
}

#Preview {
    RestView(size: 500, duration: Note.Duration.whole, isDotted: true)
}
