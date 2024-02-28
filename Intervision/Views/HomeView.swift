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
    @State var showView: Bool = false
    @State var presentedView: PresentedView = .Score
    
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
                                        rollViewModel.addAllParts()
                                    }
                                    
                                    showView.toggle()
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
                .navigationDestination(isPresented: $showView) {
                    switch presentedView {
                    case .Score:
                        ScoreView(presentedView: $presentedView, scoreViewModel: scoreViewModel)
                            .navigationBarBackButtonHidden()
                    case .Roll:
                        RollView(presentedView: $presentedView, rollViewModel: rollViewModel)
                            .navigationBarBackButtonHidden()
                    case .None:
                        HomeView()
                    }
                }
            }
        }
    }
}

extension HomeView {
    enum PresentedView: String, CaseIterable {
        case Score
        case Roll
        case None
    }
}

#Preview {
    HomeView()
}
