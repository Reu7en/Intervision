//
//  HomeView.swift
//  Intervision
//
//  Created by Reuben on 11/02/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    
    @ObservedObject var scoreManager: ScoreManager
    
    @StateObject var scoreViewModel: ScoreViewModel
    @StateObject var rollViewModel: RollViewModel
    @StateObject var testingViewModel: TestingViewModel
    @StateObject var screenSizeViewModel: ScreenSizeViewModel
    
    @State var showView: Bool = false
    @State var presentedView: PresentedView = .Roll
    
    init() {
        let scoreManager = ScoreManager()
        _scoreViewModel = StateObject(wrappedValue: ScoreViewModel(scoreManager: scoreManager))
        _rollViewModel = StateObject(wrappedValue: RollViewModel(scoreManager: scoreManager))
        _testingViewModel = StateObject(wrappedValue: TestingViewModel())
        _screenSizeViewModel = StateObject(wrappedValue: ScreenSizeViewModel())
        _scoreManager = ObservedObject(wrappedValue: scoreManager)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            NavigationStack {
                ZStack {
                    VStack {
                        Image("LaunchScreenIcon")
                            .interpolation(.high)
                            .resizable()
                            .scaledToFit()
                            .frame(width: width / 15)
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Text("New")
                                Spacer()
                                Image(systemName: "pencil")
                            }
                            .padding()
                        }
                        .frame(width: width / 10)
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
                                            showView.toggle()
                                        }
                                    }
                                }
                            }
                            #endif
                        } label: {
                            HStack {
                                Text("Open")
                                Spacer()
                                Image(systemName: "folder")
                            }
                            .padding()
                        }
                        .frame(width: width / 10)
                        .disabled(true)
                        
                        Button {
                            presentedView = .Testing
                            showView.toggle()
                        } label: {
                            HStack {
                                Text("Testing")
                                Spacer()
                                Image(systemName: "graduationcap")
                            }
                            .padding()
                        }
                        .frame(width: width / 10)
                        
                        Text("[User Testing Build]")
                    }
                    .padding()
                    .padding(.horizontal, width / 20)
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
                    if scoreManager.score != nil {
                        switch presentedView {
                        case .Score:
                            ScoreView(presentedView: $presentedView, scoreViewModel: scoreViewModel)
                                .navigationBarBackButtonHidden()
                        case .Roll:
                            RollView(presentedView: $presentedView, rollViewModel: rollViewModel)
                                .navigationBarBackButtonHidden()
                        case .None:
                            HomeView()
                        default:
                            HomeView()
                        }
                    } else {   
                        switch presentedView {
                        case .Testing:
                            TestingHomeView(testingViewModel: testingViewModel)
                                .environmentObject(screenSizeViewModel)
                                .navigationBarBackButtonHidden()
                        case .None:
                            HomeView()
                        default:
                            HomeView()
                        }
                    }
                }
                .onAppear {
                    screenSizeViewModel.screenSize = geometry.size
                }
                .onChange(of: geometry.size) {
                    screenSizeViewModel.screenSize = geometry.size
                }
            }
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
