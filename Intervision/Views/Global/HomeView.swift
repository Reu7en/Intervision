//
//  HomeView.swift
//  Intervision
//
//  Created by Reuben on 11/02/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    
    @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel
    
    @ObservedObject var scoreManager: ScoreManager
    
    @StateObject var scoreViewModel: ScoreViewModel
    @StateObject var rollViewModel: RollViewModel
    @StateObject var testingViewModel: TestingViewModel
    
    @State var presentedView: PresentedView = .Roll
    
    init() {
        let scoreManager = ScoreManager()
        _scoreViewModel = StateObject(wrappedValue: ScoreViewModel(scoreManager: scoreManager))
        _rollViewModel = StateObject(wrappedValue: RollViewModel(scoreManager: scoreManager))
        _testingViewModel = StateObject(wrappedValue: TestingViewModel())
        _scoreManager = ObservedObject(wrappedValue: scoreManager)
    }
    
    var body: some View {
        GeometryReader { geometry in
            if scoreManager.score != nil {
                switch presentedView {
                case .Score:
                    ScoreView(presentedView: $presentedView, scoreViewModel: scoreViewModel)
                        .navigationBarBackButtonHidden()
                case .Roll:
                    RollView(presentedView: $presentedView, rollViewModel: rollViewModel)
                        .navigationBarBackButtonHidden()
                default:
                    HomePanel(scoreManager: scoreManager, presentedView: $presentedView, geometry: geometry)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .environmentObject(screenSizeViewModel)
                }
            } else {
                switch presentedView {
                case .Testing:
                    TestingHomeView(testingViewModel: testingViewModel)
                        .environmentObject(screenSizeViewModel)
                        .navigationBarBackButtonHidden()
                default:
                    HomePanel(scoreManager: scoreManager, presentedView: $presentedView, geometry: geometry)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            
            Color.clear
                .onAppear {
                    screenSizeViewModel.screenSize = geometry.size
                }
                .onChange(of: geometry.size) {
                    screenSizeViewModel.screenSize = geometry.size
                }
        }
    }
}

extension HomeView {
    struct HomePanel: View {
        
        @EnvironmentObject var screenSizeViewModel: ScreenSizeViewModel

        @StateObject var scoreManager: ScoreManager
        
        @Binding var presentedView: HomeView.PresentedView
        
        let geometry: GeometryProxy
        
        var body: some View {
            #if os(macOS)
            let size = CGSize(width: geometry.size.width / 3, height: geometry.size.width / 3)
            #elseif os(iOS)
            let size = CGSize(width: geometry.size.width / 2, height: geometry.size.width / 2)
            #endif
            
            ZStack {
                VStack {
                    Image("LaunchScreenIcon")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.width / 2)
                        .equivalentPadding()
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        HStack {
                            Text("New")
                                .equivalentFont(.title)
                            
                            Spacer()
                            
                            Image(systemName: "pencil")
                        }
                        .equivalentPadding()
                    }
                    .frame(width: size.width / 1.5)
                    .disabled(true)
                    
                    Button {
                    #if os(macOS)
                        let panel = NSOpenPanel()
                        
                        panel.allowedContentTypes = [UTType.musicXML]
                        panel.allowsMultipleSelection = false
                        panel.canChooseDirectories = false
                        
                        if panel.runModal() == .OK {
                            if let fileURL = panel.urls.first {
                                MusicXMLDataService.readXML(fileURL.standardizedFileURL.path) { score in
                                    DispatchQueue.main.async {
                                        scoreManager.updateScore(newScore: score)
                                    }
                                }
                            }
                        }
                    #endif
                    } label: {
                        HStack {
                            Text("Open MusicXML")
                                .equivalentFont(.title)
                            
                            Spacer()
                            
                            Image(systemName: "folder")
                        }
                        .equivalentPadding()
                    }
                    .frame(width: size.width / 1.5)
                    .disabled(true)
                    
                    Button {
                        withAnimation(.easeInOut) {
                            presentedView = .Testing
                        }
                    } label: {
                        HStack {
                            Text("Testing")
                                .equivalentFont(.title)
                            
                            Spacer()
                            
                            Image(systemName: "graduationcap")
                        }
                        .equivalentPadding()
                    }
                    .frame(width: size.width / 1.5)
                    
                    Spacer()
                    
                    Text("[User Testing Build]")
                }
            }
            .environmentObject(screenSizeViewModel)
            .frame(width: size.width, height: size.height)
            .equivalentPadding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Material.ultraThickMaterial)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.2))
                    }
                    .shadow(radius: 10)
            )
        }
    }
}

extension HomeView {
    enum PresentedView: String, CaseIterable {
        case Score
        case Roll
        case Testing
        case None
    }
}

extension UTType {
    static var musicXML: UTType {
        UTType(exportedAs: "com.reuben.musicxml")
    }
}

#Preview {
    HomeView()
}
