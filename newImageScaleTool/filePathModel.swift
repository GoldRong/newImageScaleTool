//
//  filePathModel.swift
//  newImageScaleTool
//
//  Created by mikun on 2017/8/10.
//  Copyright © 2017年 mikun. All rights reserved.
//

import Cocoa

class filePathModel:NSObject{
    var showOriName:String?
    var fileOriName:String?
    var showTargetName:String?
    var fileTargetName:String?

    var progress:String?
    
    
    convenience init(fileOriName:String?,fileTargetName:String?,progress:String?) {
        self.init()
        self.fileOriName = fileOriName
        self.showOriName = getFileNameOnlyFrom(fullPath: fileOriName!)
        self.fileTargetName = fileTargetName
        self.showTargetName = getFileNameOnlyFrom(fullPath: fileTargetName!)
        self.progress = progress
    }
	
	func getFileNameOnlyFrom(fullPath:String) ->(String){
		var fileName = ((fullPath as NSString).lastPathComponent as NSString).deletingPathExtension
		
		guard let scaleRange = fileName.range(of: "@") else {return fileName }
		
		let subfix = fileName.substring(from: scaleRange.upperBound)
		
		if subfix.characters.count == 2 {
			var ch = ((subfix as NSString).substring(to: 1)as NSString)
			if ch as String == "\(ch.integerValue)" {
				ch = ((subfix as NSString).substring(with: NSRange(location: 1, length: 1)) as NSString)
				if ch == "x" {
					fileName = fileName.substring(to: scaleRange.lowerBound)
					fileName += "_"
				}
			}
		}
		
		return fileName
	}
}
