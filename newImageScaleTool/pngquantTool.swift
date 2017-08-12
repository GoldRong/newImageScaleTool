//
//  pngquantTool.swift
//  newImageScaleTool
//
//  Created by mikun on 2017/8/12.
//  Copyright © 2017年 mikun. All rights reserved.
//

import Cocoa

class pngquantTool: NSObject {
    
    private static let bundlePath:URL = {
        guard var bundlePath = URL(string: Bundle.main.bundlePath) else { return URL.init(fileURLWithPath: "")}
        bundlePath.appendPathComponent("Contents", isDirectory: true)
        bundlePath.appendPathComponent("Resources", isDirectory: true)
        bundlePath.appendPathComponent("pngquant", isDirectory: false)
        return bundlePath
    }()
    
    static func convertImage(path:String,arguments arg:[String]) ->(){
        var arguments = arg
        arguments.append(path)
        
        
        let pngquant = bundlePath.path
        
        
        #if DEBUG
            let result = runCommand(launchPath: pngquant, arguments: arguments)
            print(result)
        #else
            runCommand(launchPath: pngquant, arguments: arguments)
        #endif
        
    }
    
    
    /// 执行命令行,代码修改自:http://www.jianshu.com/p/5c90250943fe
    /// - parameter launchPath: 命令行启动路径
    /// - parameter arguments: 命令行参数
    /// returns: 命令行执行结果
    private static func runCommand(launchPath: String, arguments: [String]) -> String {
        let pipe = Pipe()
        let file = pipe.fileHandleForReading
        
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        task.standardOutput = pipe
        task.launch()
        
        let data = file.readDataToEndOfFile()
        return String(data: data, encoding: String.Encoding.utf8)!
    }
}
