//
//  HomeView.swift
//  Intervision
//
//  Created by Reuben on 11/02/2024.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var musicXML: UTType {
        UTType(exportedAs: "com.example.musicxml")
    }
}

struct HomeView: View {
    
    @StateObject var scoreViewModel = ScoreViewModel(score: nil)
    @StateObject var rollViewModel = RollViewModel(score: nil)
    @State private var showScoreView: Bool = false
    @State private var showRollView: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            NavigationStack {
                ZStack {
                    VStack {
                        Spacer()
                        
                        Image(systemName: "pianokeys")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width / 20)
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Text("New")
                                Spacer()
                                Image(systemName: "pencil")
                            }
                            .padding()
                        }
                        .frame(width: width / 5)
                        
                        Button {
                            let panel = NSOpenPanel()
                            
                            panel.allowedContentTypes = [UTType.musicXML]
                            panel.allowsMultipleSelection = false
                            panel.canChooseDirectories = false
                            
                            if panel.runModal() == .OK {
                                if let fileURL = panel.urls.first {
                                    let parsedScore = MusicXMLDataService.readXML(fileURL.standardizedFileURL.path)
                                    
                                    DispatchQueue.main.async {
                                        self.scoreViewModel.score = parsedScore
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.rollViewModel.score = parsedScore
                                        rollViewModel.setAllParts()
//                                        rollViewModel.setPart(partIndex: 2)
                                    }
                                    
//                                    showScoreView.toggle()
                                    showRollView.toggle()
                                }
                            }
                        } label: {
                            HStack {
                                Text("Open")
                                Spacer()
                                Image(systemName: "folder")
                            }
                            .padding()
                        }
                        .frame(width: width / 5)
                        
                        Spacer()
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
                .navigationDestination(isPresented: $showScoreView) {
                    ScoreView(scoreViewModel: scoreViewModel)
                        .navigationBarBackButtonHidden()
                }
                .navigationDestination(isPresented: $showRollView) {
                    RollView(rollViewModel: rollViewModel)
                        .navigationBarBackButtonHidden()
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
