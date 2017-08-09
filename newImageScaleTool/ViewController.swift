//
//  ViewController.swift
//  newImageScaleTool
//
//  Created by mikun on 2017/8/9.
//  Copyright © 2017年 mikun. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,NSOpenSavePanelDelegate {
	@IBOutlet weak var directoryText: NSTextField!
	
	lazy var allowedFileTypes  = ["jpg",
	                              "jpeg",
	                              "png",
	                              "bmp",
	                              "icon",
	                              "tiff"]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
	}
	
	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	@IBAction func clickOpenDirectory_File(_ sender: NSButton) {
		let openPanel = NSOpenPanel()
		openPanel.canChooseFiles = true
		openPanel.canChooseDirectories = true
		openPanel.allowsOtherFileTypes = false
		openPanel.allowsMultipleSelection = true
		openPanel.showsHiddenFiles = false
		openPanel.allowedFileTypes = allowedFileTypes
		openPanel.delegate = self
		if openPanel.runModal() == NSModalResponseOK {
			directoryText.stringValue = (openPanel.directoryURL?.absoluteString)!
		}
	}
	@IBAction func clickSacleImage(_ sender: Any) {
		let image = NSImage(contentsOfFile: directoryText.stringValue)
		guard
			let tiffData = image?.tiffRepresentation ,
			let bitRep = NSBitmapImageRep(data: tiffData)
		else{ return }
		
		bitRep.size = CGSize(width: 100, height: 100)
		guard
			let imagePNG = bitRep.representation(using: .PNG, properties: [:])
		else { return }
		(directoryText.stringValue as NSString).pathExtension
		pathURL.deletePathExtension()
		guard
			let pathPngURL = URL(string: pathURL.absoluteString+".png" )
		else { return }
		
		do {
			try imagePNG.write(to: pathPngURL, options: .atomic)
		} catch{
			print(error)
		}
		
	}

	
	func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
		print(url.absoluteString)
		let ext = url.pathExtension
		if !ext.isEmpty {
			for allowExt in allowedFileTypes {
				if ext == allowExt {
					return true
				}
			}
			return false
		}
		return true
	}
}

