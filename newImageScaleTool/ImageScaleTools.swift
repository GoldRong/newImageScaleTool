//
//  ImageScaleTools.swift
//  newImageScaleTool
//
//  Created by mikun on 2017/8/10.
//  Copyright © 2017年 mikun. All rights reserved.
//

import Cocoa

extension NSImage{
    var realSize: CGSize {
        get {
            let rep = self.representations[0]
            
            return CGSize(width: rep.pixelsWide, height: rep.pixelsHigh)
        }
        
    }
    
    var PNGData: Data? {
        get {
            guard
                let tiffData = self.tiffRepresentation ,
                let bitRep = NSBitmapImageRep(data: tiffData)
            else{ return nil}
            
            bitRep.size = CGSize(width: self.realSize.width, height: self.realSize.height)
            return bitRep.representation(using: .PNG, properties: [:])
        }
        
    }
}

class ImageScaleTools: NSObject {
    
    
    static func creatScale(image:NSImage , size1x:CGSize , scaleRatio:Int) -> NSImage? {
        let width = Int(size1x.width)*scaleRatio
        let height = Int(size1x.height)*scaleRatio
        
        guard
            let cgImageOri = createCGImageRefFrom(NSImage: image),
            let cgImageScale = createScale(CGImage: cgImageOri,ByWidth : width, height: height)
        else{ return nil}
        
        return NSImage(cgImage: cgImageScale, size: CGSize(width: width, height: height))
    }
    
    static func createCGImageRefFrom(NSImage image: NSImage) -> CGImage? {
        let option = [kCGImageSourceShouldCache as String:kCFBooleanTrue as Bool,
                      kCGImageSourceShouldAllowFloat as String:kCFBooleanTrue as Bool]
        guard
            let tiffData = image.tiffRepresentation ,
            let cgImageSource = CGImageSourceCreateWithData(tiffData as CFData, nil) ,
            let cgImage = CGImageSourceCreateImageAtIndex(cgImageSource, 0, option as CFDictionary)
            else{return nil}
        
        return cgImage
    }
    
    static func createScale(CGImage image:CGImage,ByWidth width:Int,height:Int) -> CGImage? {
        let content = createBitmapContextWith(width: width, height: height)
        content?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return content?.makeImage()
    }
    
    static func createBitmapContextWith(width:Int,height:Int) -> CGContext? {
        
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * height
        
        let bitmapData = calloc(bitmapByteCount, MemoryLayout<GLubyte>.size).assumingMemoryBound(to: GLubyte.self)
        
        guard let context = CGContext(data: bitmapData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        
        return context
    }
    
    
    static func get1xSizeFrom(image:NSImage ,sourceRatio:Int) -> CGSize {
        
        let oriSize = image.realSize
        
        let targetFloatWidth = oriSize.width/CGFloat(sourceRatio)
        
        let targetIntWidth = Int(round(targetFloatWidth))
        
        
        let targetFloatHeight = oriSize.height/CGFloat(sourceRatio)
        
        let targetIntHeight = Int(round(targetFloatHeight))
        
        return CGSize(width: targetIntWidth, height: targetIntHeight)
        
    }
    
    static func save(image:NSImage , to path:String) -> () {
        do {
            try image.PNGData?.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch{
            let alert = NSAlert(error: error)
            alert.beginSheetModal(for: NSApplication.shared().keyWindow!, completionHandler: nil)
        }
    }
    

    

}
