//
//  ProcessFiles.swift
//  Icon Generator
//
//  Created by Vaida on 7/12/22.
//

import Foundation
import Support
import SwiftUI


extension Array where Element == FinderItem {
    
    @discardableResult
    func process(option: ContentView.Options, isFinished: Binding<Bool>, progress: Binding<Double>, generatesIntoFolder: Bool, replaceFile: Bool = true) -> [FinderItem] {
        var destinatioN: [FinderItem] = []
        
        for finderItem in self {
            var image: NativeImage {
                if option == .customImage {
                    return CustomImage(image: finderItem.image!).saveImage(size: CGSize(width: 1350, height: 1350))
                } else {
                    return finderItem.image!.embedInSquare()!
                }
            }
            
            let destinationFolder = generatesIntoFolder ? FinderItem.output : FinderItem.temporaryDirectory.with(subPath: UUID().description)
            
            if option == .normal || option == .customImage {
                let destination = destinationFolder.with(subPath: finderItem.relativePath ?? finderItem.name)
                destination.generateDirectory()
                try! image.write(to: destination, option: .icns)
                destination.extensionName = ".icns"
                
                if replaceFile { finderItem.path = destination.path }
                destinatioN.append(destination)
            } else if option == .xcodeMac {
                let destination = destinationFolder.with(subPath: "AppIcon.appiconset")
                print(image, destination)
                destination.generateOutputPath()
                destination.generateDirectory(isFolder: true)
                
                let sizes = [16, 32, 64, 128, 256, 512, 1024]
                sizes.iterated(isConcurrent: true) { _, size  in
                    try? image.resized(to: NSSize(width: size, height: size))!.write(to: destination.with(subPath: "icon_\(size)x\(size).heic"), option: .heic)
                }
                FinderItem(at: Bundle.main.url(forResource: "Mac", withExtension: "json")!).copy(to: destination.with(subPath: "Contents.json"))
                
                if replaceFile { finderItem.path = destination.path }
                destinatioN.append(destination)
            } else if option == .xcodeFull {
                let destination = destinationFolder.with(subPath: "AppIcon.appiconset")
                destination.generateOutputPath()
                destination.generateDirectory(isFolder: true)
                
                let sizes = [16, 20, 29, 32, 40, 58, 60, 64, 76, 80, 87, 120, 128, 152, 167, 180, 256, 512, 1024]
                for size in sizes {
                    try? image.resized(to: NSSize(width: size, height: size))!.write(to: destination.with(subPath: "icon_\(size)x\(size).heic"), option: .heic)
                }
                FinderItem(at: Bundle.main.url(forResource: "Full", withExtension: "json")!).copy(to: destination.with(subPath: "Contents.json"))
                
                if replaceFile { finderItem.path = destination.path }
                destinatioN.append(destination)
            }
            progress.wrappedValue += 1 / Double(self.count)
        }
        
        isFinished.wrappedValue = true
        FinderItem.output.setIcon(image: NSImage(imageLiteralResourceName: "icon"))
        
        return destinatioN
    }
    
}
