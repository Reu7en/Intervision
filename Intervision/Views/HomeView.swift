//
//  HomeView.swift
//  Intervision
//
//  Created by Reuben on 11/02/2024.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                VStack {
                    Image(systemName: "pianokeys")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: height / 9)
                    
                    Button {
                        
                    } label: {
                        HStack {
                            Text("New")
                            Spacer()
                            Image(systemName: "pencil")
                        }
                        .padding()
                    }
                    
                    Button {
                        
                    } label: {
                        HStack {
                            Text("Open")
                            Spacer()
                            Image(systemName: "folder")
                        }
                        .padding()
                    }
                }
                .padding()
                .frame(width: width / 3, height: height / 3)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Material.ultraThickMaterial)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.2))
                        }
                )
                .shadow(radius: 10)
            }
            .position(x: width / 2, y: height / 2)
        }
    }
}

#Preview {
    HomeView()
}
