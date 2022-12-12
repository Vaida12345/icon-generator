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
    func process(option: ContentView.Options, isFinished: Binding<Bool>, progress: Binding<Double>, generatesIntoFolder: Bool, replaceFile: Bool = true) throws -> [FinderItem] {
        var finalDestinations: [FinderItem] = []
        
        for item in self {
            let destination: FinderItem
            guard let image = item.image else { continue }
            let resultImage = option == .customImage ? CustomImage(image: image).saveImage(size: CGSize(width: 1350, height: 1350)) : image
            
            let destinationFolder = generatesIntoFolder ? FinderItem.output : FinderItem.temporaryDirectory.with(subPath: UUID().description)
            
            if option == .normal || option == .customImage {
                destination = destinationFolder.with(subPath: item.relativePath ?? item.name)
                try destination.generateDirectory()
                try resultImage.write(to: destination, option: .icns)
                destination.extensionName = ".icns"
                
                finalDestinations.append(destination)
            } else if option == .xcodeMac {
                destination = destinationFolder.with(subPath: "AppIcon.appiconset")
                try destination.generateOutputPath()
                try destination.generateDirectory(isFolder: true)
                
                let sizes = [16, 32, 64, 128, 256, 512, 1024]
                sizes.concurrentForEach { size  in
                    try? resultImage.cgImage!.resized(to: NSSize(width: size, height: size))!.write(to: destination.with(subPath: "icon_\(size)x\(size).heic"), option: .heic)
                }
                try FinderItem.bundleItem(forResource: "Mac", withExtension: "json")!.copy(to: destination.with(subPath: "Contents.json"))
                
            } else if option == .xcodeFull {
                destination = destinationFolder.with(subPath: "AppIcon.appiconset")
                try destination.generateOutputPath()
                try destination.generateDirectory(isFolder: true)
                
                let sizes = [16, 20, 29, 32, 40, 58, 60, 64, 76, 80, 87, 120, 128, 152, 167, 180, 256, 512, 1024]
                for size in sizes {
                    try? resultImage.cgImage!.resized(to: NSSize(width: size, height: size))!.write(to: destination.with(subPath: "icon_\(size)x\(size).heic"), option: .heic)
                }
                try FinderItem.bundleItem(forResource: "Full", withExtension: "json")!.copy(to: destination.with(subPath: "Contents.json"))
                
            } else {
                fatalError()
            }
            
            finalDestinations.append(destination)
            progress.wrappedValue += 1 / Double(self.count)
        }
        
        isFinished.wrappedValue = true
        FinderItem.output.setIcon(image: NSImage(imageLiteralResourceName: "icon"))
        
        return finalDestinations
    }
    
}
