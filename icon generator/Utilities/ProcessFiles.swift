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
    
    @MainActor @discardableResult
    func process(option: ContentView.Options, isFinished: Binding<Bool>, progress: Binding<Double>, generatesIntoFolder: Bool, replaceFile: Bool = true) async throws -> [FinderItem] {
        var finalDestinations: [FinderItem] = []
        
        for item in self {
            let destination: FinderItem
            guard let image = item.image else { continue }
            let resultImage = await option == .customImage ? CustomImage(image: image).saveImage(size: CGSize(width: 1350, height: 1350)) : image
            
            let destinationFolder = generatesIntoFolder ? FinderItem.output : FinderItem.temporaryDirectory.with(subPath: UUID().description)
            
            switch option {
            case .normal, .customImage:
                destination = destinationFolder.with(subPath: item.relativePath ?? item.name)
                try destination.generateDirectory()
                try resultImage.write(to: destination, option: .icns)
                destination.extension = "icns"
                
                finalDestinations.append(destination)
                
            case .xcodeMac:
                destination = destinationFolder.with(subPath: "AppIcon.appiconset")
                try destination.generateOutputPath()
                try destination.generateDirectory(isFolder: true)
                
                let sizes = [16, 32, 64, 128, 256, 512, 1024]
                sizes.concurrent.forEach { size  in
                    try? resultImage.cgImage!.resized(to: NSSize(width: size, height: size))!.write(to: destination.with(subPath: "icon_\(size)x\(size).png"), option: .png)
                }
                try FinderItem.bundleItem(forResource: "Mac", withExtension: "json")!.copy(to: destination.with(subPath: "Contents.json"))
                
            case .xcodeFull:
                destination = destinationFolder.with(subPath: "AppIcon.appiconset")
                try destination.generateOutputPath()
                try destination.generateDirectory(isFolder: true)
                
                let sizes = [16, 20, 29, 32, 40, 58, 60, 64, 76, 80, 87, 120, 128, 152, 167, 180, 256, 512, 1024]
                for size in sizes {
                    try? resultImage.cgImage!.resized(to: NSSize(width: size, height: size))!.write(to: destination.with(subPath: "icon_\(size)x\(size).png"), option: .png)
                }
                try FinderItem.bundleItem(forResource: "Full", withExtension: "json")!.copy(to: destination.with(subPath: "Contents.json"))
                
            }
            
            finalDestinations.append(destination)
            progress.wrappedValue += 1 / Double(self.count)
        }
        
        isFinished.wrappedValue = true
        FinderItem.output.setIcon(image: NSImage(imageLiteralResourceName: "icon"))
        
        return finalDestinations
    }
    
}
