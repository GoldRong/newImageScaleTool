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
        self.showOriName = (fileOriName! as NSString).lastPathComponent
        self.fileTargetName = fileTargetName
        self.showTargetName = (fileTargetName! as NSString).lastPathComponent
        self.progress = progress
    }
}
