//
//  ViewController.swift
//  newImageScaleTool
//
//  Created by mikun on 2017/8/9.
//  Copyright © 2017年 mikun. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,NSOpenSavePanelDelegate,NSTableViewDataSource,NSTableViewDelegate
{
    @IBOutlet weak var finishLabel: NSTextField!
    
	@IBOutlet weak var directoryText: NSTextField!
	
    @IBOutlet weak var sourceComboBox: NSComboBox!
    
    @IBOutlet weak var targetSelectItemsView: NSView!
    
    lazy var targetCount = 0
    
    lazy var finishCount = 0
    
    @IBOutlet weak var tableview: NSTableView!

    
    lazy var ArrFilePath = Array<filePathModel>()
    
    
	lazy var allowedFileTypes  = ["jpg",
	                              "jpeg",
	                              "png",
	                              "bmp",
	                              "icon",
	                              "tiff"]
	
	override func viewDidLoad() {
		super.viewDidLoad()
        sourceComboBox.selectItem(at: 3)
        directoryText.becomeFirstResponder()
        finishLabel.isHidden = true
        
        tableview.dataSource = self
        tableview.delegate = self
		// Do any additional setup after loading the view.
	}
	
	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	@IBAction func clickOpenDirectory_File(_ sender: NSButton) {
        ArrFilePath.removeAll()
		let openPanel = NSOpenPanel()
		openPanel.canChooseFiles = true
		openPanel.canChooseDirectories = true
		openPanel.allowsOtherFileTypes = false
		openPanel.allowsMultipleSelection = true
		openPanel.showsHiddenFiles = false
		openPanel.allowedFileTypes = allowedFileTypes
		openPanel.delegate = self
		if openPanel.runModal() == NSModalResponseOK {
            guard let url = openPanel.url else {return}
            let pathStr = removeFileHeaders(path: url.path)
            print(pathStr)
            let fm = FileManager.default
            
            var isDirectory:ObjCBool = false
            
            if fm.fileExists(atPath: pathStr, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    guard let paths = fm.subpaths(atPath: pathStr) else { return }
                    for path in paths {
                        for ext in allowedFileTypes {
                            if (path as NSString).pathExtension == ext{
                                let fullPath = (pathStr as NSString).appendingPathComponent(path)
                                ArrFilePath.append(filePathModel(fileOriName: fullPath, fileTargetName: fullPath, progress: ""))
                            }
                        }
                    }
                }else{
                    directoryText.stringValue = pathStr
                    ArrFilePath.append(filePathModel(fileOriName: pathStr, fileTargetName: pathStr, progress: ""))
                }
            }
            tableview.reloadData()


		}
	}
    
    func removeFileHeaders(path:String) -> String {
        let fileRange = path.range(of: "file://")
        if (fileRange?.isEmpty)! {
            return path
        }else{
            return path.substring(from: (fileRange?.upperBound)!)
        }
    }
	@IBAction func clickSacleImage(_ sender: Any) {
        targetCount = 0
        finishCount = 0
        for selectView in targetSelectItemsView.subviews {
            if selectView.isKind(of: NSButton.self) {
                let selectBotton = selectView as! NSButton
                if selectBotton.state == 1 && selectBotton.isEnabled {
                    targetCount += 1
                }
            }
        }
        finishCount += 1
        
        finishLabel.isHidden = true

        for pathModel in ArrFilePath {
            guard let path = pathModel.fileOriName else { return }
            self.handleImageWith(path: path)
        }

	}
    
    func handleImageWith(path:String) -> () {
        guard let image = NSImage(contentsOfFile: directoryText.stringValue) else { return }
        
        
        let size1x = ImageScaleTools.get1xSizeFrom(image: image, sourceRatio: sourceComboBox.indexOfSelectedItem+1)
        
        for selectView in targetSelectItemsView.subviews {
            if selectView.isKind(of: NSButton.self) {
                let selectBotton = selectView as! NSButton
                if selectBotton.state == 1 && selectBotton.isEnabled {
                    guard let newimage = ImageScaleTools.creatScale(image: image, size1x: size1x, scaleRatio: selectView.tag) else { return }
                    
                    var pathString = directoryText.stringValue
                    let OCpathString = (pathString as NSString).deletingPathExtension
                    pathString = OCpathString as String
                    pathString += "@\(selectView.tag)x.png"
                    
                    ImageScaleTools.save(image: newimage, to: pathString)
                }
            }
            
        }
    }
    
    func showFinishLabel() -> () {
        finishLabel.alphaValue = 0;
        finishLabel.isHidden = false
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.25
            finishLabel.animator().alphaValue = 1
        }, completionHandler: nil)
    }
    
    @IBAction func sourceComboBoxDidSelected(_ sender: NSComboBox) {
        for selectView in targetSelectItemsView.subviews {
            if selectView.isKind(of: NSButton.self) {
                let selectBotton = selectView as! NSButton
                
                selectBotton.isEnabled = selectBotton.tag-1<sender.indexOfSelectedItem
            }
        }
    }
    
    
//MARK:	NSOpenSavePanelDelegate
//	func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
//		print(url.absoluteString)
//		let ext = url.pathExtension
//		if !ext.isEmpty {
//			for allowExt in allowedFileTypes {
//				if ext == allowExt {
//                    
//                    
//					return true
//				}
//			}
//			return false
//		}
//		return true
//	}

//MARK:	NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ArrFilePath.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        return ArrFilePath[row]
    }
    
//MARK:	NSTableViewDelegate
    
    
}

