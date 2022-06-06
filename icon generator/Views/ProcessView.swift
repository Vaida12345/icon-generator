//
//  ProcessView.swift
//  icon generator
//
//  Created by Vaida on 6/6/22.
//

import Foundation
import SwiftUI
import Support


struct ProcessingView: View {
    
    @Binding var finderItems: [FinderItem]
    @Binding var isAppear: Bool
    @Binding var option: ContentView.Options
    
    @State var isFinished: Bool = false
    @State var progress: Double = 0
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Status: ")
                
                Text(isFinished ? "Finished" : "Processing")
                
                Spacer()
            }
            .padding([.horizontal, .top])
            
            ProgressView(value: isFinished ? 1 : progress)
                .padding([.horizontal, .top])
            
            if isFinished {
                HStack {
                    Spacer()
                    
                    Button {
                        FinderItem.output.revealInFinder()
                        isAppear = false
                    } label: {
                        Text("Show in Finder")
                            .padding()
                    }
                    .padding(.trailing)
                    
                    Button {
                        isAppear = false
                    } label: {
                        Text("Done")
                            .padding()
                    }
                    .keyboardShortcut(.defaultAction)
                }
                .padding()
            } else {
                HStack {
                    Spacer()
                    
                    Button("Cancel") {
                        exit(0)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            DispatchQueue(label: "utility").async {
                for finderItem in finderItems {
                    var image: NativeImage {
                        if option == .customImage {
                            return CustomImage(image: finderItem.image!).saveImage(size: CGSize(width: 1350, height: 1350))
                        } else {
                            return finderItem.image!.embedInSquare()!
                        }
                    }
                    
                    if option == .normal || option == .customImage {
                        let destination = FinderItem.output.with(subPath: finderItem.relativePath ?? finderItem.name)
                        destination.generateDirectory()
                        try? image.write(to: destination, option: .icns)
                        destination.extensionName = ".icns"
                    } else if option == .xcodeMac {
                        let destination = FinderItem.output.with(subPath: "AppIcon.appiconset")
                        destination.generateOutputPath()
                        destination.generateDirectory(isFolder: true)
                        
                        let sizes = [16, 32, 64, 128, 256, 512, 1024]
                        for size in sizes {
                            try? image.resized(to: NSSize(width: size, height: size))!.write(to: destination.with(subPath: "icon_\(size)x\(size).heic"), option: .heic)
                        }
                        FinderItem(at: Bundle.main.url(forResource: "Mac", withExtension: "json")!).copy(to: destination.with(subPath: "Contents.json"))
                    } else if option == .xcodeFull {
                        let destination = FinderItem.output.with(subPath: "AppIcon.appiconset")
                        destination.generateOutputPath()
                        destination.generateDirectory(isFolder: true)
                        
                        let sizes = [16, 20, 29, 32, 40, 58, 60, 64, 76, 80, 87, 120, 128, 152, 167, 180, 256, 512, 1024]
                        for size in sizes {
                            try? image.resized(to: NSSize(width: size, height: size))!.write(to: destination.with(subPath: "icon_\(size)x\(size).heic"), option: .heic)
                        }
                        FinderItem(at: Bundle.main.url(forResource: "Full", withExtension: "json")!).copy(to: destination.with(subPath: "Contents.json"))
                    }
                    
                    
                    progress += 1 / Double(finderItems.count)
                }
                
                isFinished = true
                FinderItem.output.setIcon(image: NSImage(imageLiteralResourceName: "icon"))
            }
        }
        
    }
    
}
