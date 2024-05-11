//
//  HomeView.swift
//  Intervision
//
//  Created by Reuben on 11/02/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    
    @EnvironmentObject var screenSizeViewModel: DynamicSizingViewModel
    
    @StateObject var scoreManager: ScoreManager
    
    @StateObject var scoreViewModel: ScoreViewModel
    @StateObject var rollViewModel: RollViewModel
    @StateObject var testingViewModel: TestingViewModel
    
    @State var presentedView: PresentedView = .None
    @State private var opacity = 0.0
    
    init() {
        let scoreManager = ScoreManager()
        
        _scoreViewModel = StateObject(wrappedValue: ScoreViewModel(scoreManager: scoreManager))
        _rollViewModel = StateObject(wrappedValue: RollViewModel(scoreManager: scoreManager))
        _testingViewModel = StateObject(wrappedValue: TestingViewModel())
        _scoreManager = StateObject(wrappedValue: scoreManager)
    }
    
    var body: some View {
        switch presentedView {
        case .Score:
            ScoreView(presentedView: $presentedView, scoreViewModel: scoreViewModel)
        case .Roll:
            RollView(presentedView: $presentedView, rollViewModel: rollViewModel)
                .environmentObject(screenSizeViewModel)
        case .Testing:
            TestingHomeView(testingViewModel: testingViewModel, presentedHomeView: $presentedView)
                .environmentObject(screenSizeViewModel)
        case .Loading:
            ProgressView()
        default:
            HomePanel(scoreManager: scoreManager, presentedView: $presentedView, size: screenSizeViewModel.viewSize)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        opacity = 1.0
                    }
                }
        }
    }
}

extension HomeView {
    struct HomePanel: View {
        
        @EnvironmentObject var screenSizeViewModel: DynamicSizingViewModel

        @StateObject var scoreManager: ScoreManager
        
        @Binding var presentedView: HomeView.PresentedView
        
        let size: CGSize
        
        var body: some View {
            let size = CGSize(width: size.width / 2, height: size.width / 2)
            
            ZStack {
                VStack {
                    Image("LaunchScreenIcon")
                        .interpolation(.high)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.width / 2)
                        .dynamicPadding()
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        HStack {
                            Text("New")
                                .dynamicFont(.title2)
                            
                            Spacer()
                            
                            Image(systemName: "pencil")
                                .dynamicFont(.title3)
                        }
                        .dynamicPadding(.all, 50)
                    }
//                    .disabled(true)
                    .buttonStyle(BorderedButtonStyle())
                    .frame(width: size.width / 1.5)
                    .dynamicPadding()
                    
                    Button {
                    #if os(macOS)
                        let panel = NSOpenPanel()
                        
                        panel.allowedContentTypes = [UTType.musicXML]
                        panel.allowsMultipleSelection = false
                        panel.canChooseDirectories = false
                        
                        if panel.runModal() == .OK {
                            if let fileURL = panel.urls.first {
                                Task {
                                    withAnimation(.easeInOut) {
                                        presentedView = .Loading
                                    }
                                    
                                    await scoreManager.score = MusicXMLDataService.readXML(fileURL.standardizedFileURL.path)
                                    
                                    withAnimation(.easeInOut) {
                                        presentedView = .Score
                                    }
                                }
                            }
                        }
                    #endif
                    } label: {
                        HStack {
                            Text("Open MusicXML")
                                .dynamicFont(.title2)
                            
                            Spacer()
                            
                            Image(systemName: "folder")
                                .dynamicFont(.title3)
                        }
                        .dynamicPadding(.all, 50)
                    }
//                    .disabled(true)
                    .buttonStyle(BorderedButtonStyle())
                    .frame(width: size.width / 1.5)
                    .dynamicPadding()
                    
                    Button {
                        withAnimation(.easeInOut) {
                            presentedView = .Testing
                        }
                    } label: {
                        HStack {
                            Text("Testing")
                                .dynamicFont(.title2)
                            
                            Spacer()
                            
                            Image(systemName: "graduationcap")
                                .dynamicFont(.title3)
                        }
                        .dynamicPadding(.all, 50)
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .frame(width: size.width / 1.5)
                    .dynamicPadding()
                    
                    Spacer()
                    
                    Text("[User Testing Build]")
                        .dynamicFont(.title3)
                        .dynamicPadding()
                        .fontWeight(.semibold)
                }
            }
            .environmentObject(screenSizeViewModel)
            .frame(width: size.width, height: size.height)
            .dynamicPadding(.all, 50)
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
            #if os(macOS)
            .scaleEffect(0.5)
            #endif
        }
    }
}

extension HomeView {
    enum PresentedView: String, CaseIterable {
        case Score
        case Roll
        case Testing
        case Loading
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
