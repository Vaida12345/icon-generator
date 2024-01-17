//
//  ContentView.swift
//
//
//  Created by Vaida on 11/22/21.
//

import SwiftUI
import AVFoundation
import Nucleus


struct ContentView: View {
    @State var finderItems: [FinderItem] = []
    @State var isSheetShown: Bool = false
    
    @State private var isGenerating = false
    @State private var isFinished = false
    
    @AppStorage("chosenOption") var chosenOption: Options = .normal
    @AppStorage("mode") private var mode: ProcessMode = .export
    
    var body: some View {
        VStack {
            DropHandlerView()
                .onDrop { sources in
                    if mode == .auto {
                        Task.detached {
                            do {
                                let items = try await sources.process(option: chosenOption, generatesIntoFolder: false)
                                
                                Task { @MainActor in
                                    self.finderItems.append(contentsOf: items)
                                }
                            } catch {
                                Task { @MainActor in
                                    AlertManager(error).present()
                                }
                            }
                            
                            Task { @MainActor in
                                self.isFinished = true
                            }
                        }
                    } else {
                        finderItems.append(contentsOf: sources)
                    }
                }
                .disabled(mode == .noneDestination && isFinished)
                .overlay(hidden: finderItems.isEmpty) { _ in
                    GeometryReader { geometry in
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: .init(.fixed(200), alignment: .leading), count: min(Int(geometry.size.width) / 200, finderItems.count)), alignment: .leading) {
                                ForEach(finderItems) { item in
                                    GridItemView(finderItems: $finderItems, item: item, isFinished: isFinished, option: chosenOption)
                                }
                            }
                        }
                    }
                }
        }
        .frame(minWidth: 200)
        .sheet(isPresented: $isSheetShown) {
            withAnimation {
                self.finderItems = []
            }
        } content: {
            ProcessingView(finderItems: finderItems, option: chosenOption)
                .frame(width: 600, height: 150)
        }
        .toolbar {
            ToolbarItem {
                Picker("", selection: $chosenOption) {
                    ForEach(Options.allCases, id: \.self) {
                        Image(systemName: $0.imageName)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            ToolbarItem {
                if mode != .auto {
                    Button("Done") {
                        Task {
                            if mode == .export {
                                isSheetShown = true
                            } else {
                                isGenerating = true
                                do {
                                    try await finderItems.process(option: chosenOption, generatesIntoFolder: false)
                                } catch {
                                    AlertManager(error).present()
                                }
                                
                                self.isFinished = true
                            }
                        }
                    }
                    .disabled(finderItems.isEmpty || isSheetShown || isGenerating)
                }
            }
        }
    }
    
    enum Options: String, CaseIterable {
        case normal = "Normal"
        case xcodeMac = "Xcode Mac"
        case xcodeFull = "Xcode Full"
        case customImage = "Custom Image"
        
        var imageName: String {
            switch self {
            case .normal:
                "circle.rectangle.filled.pattern.diagonalline"
            case .xcodeMac:
                "macstudio"
            case .xcodeFull:
                "macbook.and.ipad"
            case .customImage:
                "rectangle.inset.filled"
            }
        }
    }
}
