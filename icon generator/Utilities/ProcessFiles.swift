//
//  ProcessFiles.swift
//  Icon Generator
//
//  Created by Vaida on 7/12/22.
//

import Foundation
import Nucleus
import SwiftUI


extension Array where Element == FinderItem {
    
    @discardableResult
    func process(option: ContentView.Options, generatesIntoFolder: Bool, replaceFile: Bool = true) async throws -> [FinderItem] {
        var finalDestinations: [FinderItem] = []
        
        for item in self {
            let destination: FinderItem
            guard let image = item.image() else { continue }
            let resultImage = await option == .customImage ? NativeImage(cgImage: ImageRenderer(content: CustomImage(image: image)).cgImage!)! : image
            
            let destinationFolder = generatesIntoFolder ? FinderItem.output : FinderItem.temporaryDirectory.appending(path: UUID().description)
            
            switch option {
            case .normal, .customImage:
                destination = destinationFolder.appending(path: item.name)
                try destination.generateDirectory()
                destination.extension = "icns"
                try resultImage.write(to: destination, option: .icns)
                
            case .xcodeMac:
                destination = destinationFolder.appending(path: "AppIcon.appiconset")
                try destination.generateOutputPath()
                try destination.makeDirectory()
                
                let sizes = [16, 32, 64, 128, 256, 512, 1024]
                print(destination)
                sizes.concurrent.forEach { size in
                    try? resultImage.cgImage!.resized(to: NSSize(width: size, height: size))!.write(to: destination.appending(path: "icon_\(size)x\(size).png"), option: .png)
                }
                try FinderItem.bundleItem(forResource: "Mac", withExtension: "json")!.copy(to: destination.appending(path: "Contents.json"))
                
            case .xcodeFull:
                destination = destinationFolder.appending(path: "AppIcon.appiconset")
                try destination.generateOutputPath()
                try destination.makeDirectory()
                
                let sizes = [16, 20, 29, 32, 40, 58, 60, 64, 76, 80, 87, 120, 128, 152, 167, 180, 256, 512, 1024]
                for size in sizes {
                    try? resultImage.cgImage!.resized(to: NSSize(width: size, height: size))!.write(to: destination.appending(path: "icon_\(size)x\(size).png"), option: .png)
                }
                try FinderItem.bundleItem(forResource: "Full", withExtension: "json")!.copy(to: destination.appending(path: "Contents.json"))
                
            }
            
            print(">>>>", destination)
            finalDestinations.append(destination)
        }
        
        FinderItem.output.setIcon(image: NSImage(imageLiteralResourceName: "icon"))
        
        return finalDestinations
    }
    
}
