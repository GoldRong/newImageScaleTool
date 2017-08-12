//
//  ViewController.swift
//  newImageScaleTool
//
//  Created by mikun on 2017/8/9.
//  Copyright © 2017年 mikun. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,NSOpenSavePanelDelegate,NSTableViewDataSource,NSTableViewDelegate,NSTextFieldDelegate
{
    @IBOutlet weak var finishLabel: NSTextField!
    
	@IBOutlet weak var directoryText: NSTextField!
	
    @IBOutlet weak var targetDirectoryText: NSTextField!
    
    @IBOutlet weak var sourceComboBox: NSPopUpButton!
    
    @IBOutlet weak var targetSelectItemsView: NSView!
    
    @IBOutlet weak var theadCountCombox: NSPopUpButton!
    
    @IBOutlet weak var tableview: NSTableView!
    
    
    @IBOutlet weak var enablePNGZipButton: NSButton!
    
    @IBOutlet weak var PNGZipComboBox: NSPopUpButton!


    @IBOutlet weak var saveConfigButton: NSButton!
    
    
    lazy var targetCount = 0
    
    lazy var finishCount = 0
	
	let comboBoxSelectItem = 3
	
    lazy var basePathString = ""
    

    lazy var multiThreadingQueue = OperationQueue()
    
    lazy var ArrFilePath = Array<filePathModel?>()
    
    
	lazy var allowedFileTypes  = ["jpg",
	                              "jpeg",
	                              "png",
	                              "bmp",
	                              "tiff"]
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        sourceComboBox.removeAllItems()
        for i in 1...9 {
            sourceComboBox.addItem(withTitle: "@\(i)x")
        }
        sourceComboBox.selectItem(at: comboBoxSelectItem)
        checkComboBox_SelectedButton(comboBoxIndex: comboBoxSelectItem)
        
        theadCountCombox.removeAllItems()
        for i in 1...10 {
            theadCountCombox.addItem(withTitle: "\(i)")
        }
        theadCountCombox.selectItem(at: 2)
        
        PNGZipComboBox.removeAllItems()
        PNGZipComboBox.addItem(withTitle: "低")
        PNGZipComboBox.addItem(withTitle: "中")
        PNGZipComboBox.addItem(withTitle: "高")
        PNGZipComboBox.addItem(withTitle: "自适应")
        PNGZipComboBox.selectItem(at: 3)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: NSNotification.Name.NSControlTextDidChange, object: directoryText)
        
        
        finishLabel.isHidden = true
        
		tableview.doubleAction = #selector(tableViewDidDoubleClick)

		// Do any additional setup after loading the view.
	}
    
    override func viewDidAppear() {
        directoryText.becomeFirstResponder()
    }
	
	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
    
    @IBAction func clickClearDirectory(_ sender: Any) {
        directoryText.stringValue = ""
        targetDirectoryText.stringValue = ""
        ArrFilePath.removeAll()
        tableview.reloadData()
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
            let urls = openPanel.urls
            if urls.count == 1 {
                let pathStr = removeFileHeaders(path: urls[0].path)
                
                let _ = applyDirectoryText(pathStr: pathStr)
                directoryText.stringValue = pathStr
            }else{
                for url in urls {
                    let pathStr = removeFileHeaders(path: url.path)

                    directoryText.stringValue = applyDirectoryText(pathStr: pathStr)
                }
            }

            tableview.reloadData()
		}
	}
    
    func applyDirectoryText(pathStr:String) -> (String) {
        datasourceAdd(pathStr: pathStr)
        
        let basePath = getFileBasePath(filePath: pathStr)
        
        targetDirectoryText.stringValue = URL(fileURLWithPath: basePath).appendingPathComponent("iOS", isDirectory: true).path
        basePathString = basePath
        return basePath
    }
    
    func removeFileHeaders(path:String) -> String {
		guard let fileRange = path.range(of: "file://") else {return path}
		
        if fileRange.isEmpty {
            return path
        }else{
            return path.substring(from: fileRange.upperBound)
        }
    }
    
    func getFileBasePath(filePath:String) -> String {
        

        if FileManager.default.fileExists(atPath: filePath, isDirectory: nil) {
            return (filePath as NSString).deletingLastPathComponent
        }
        
        return ""
        
    }
    
    func datasourceAdd(pathStr:String)->(){
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
                ArrFilePath.append(filePathModel(fileOriName: pathStr, fileTargetName: pathStr, progress: ""))
            }
        }

    }
    
    @IBAction func clickOpenTargetDirectory(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.allowsOtherFileTypes = false
        openPanel.allowsMultipleSelection = true
        openPanel.showsHiddenFiles = true
        if openPanel.runModal() == NSModalResponseOK {
            guard let url = openPanel.url else { return }
            let pathStr = removeFileHeaders(path: url.path)
            targetDirectoryText.stringValue = pathStr
        }
    }

    
	@IBAction func clickSacleImage(_ sender: Any) {
        targetCount = 0
        finishCount = 0
        
        let theadCount = theadCountCombox.indexOfSelectedItem+1
        multiThreadingQueue.maxConcurrentOperationCount = theadCount
        
        for selectView in targetSelectItemsView.subviews {
            if selectView.isKind(of: NSButton.self) {
                let selectBotton = selectView as! NSButton
                if selectBotton.state == 1 && selectBotton.isEnabled {
                    targetCount += 1
                }
            }
        }
        
        finishLabel.isHidden = true
        
        let finishOP = BlockOperation { 
            OperationQueue.main.addOperation({
                self.showFinishLabel()
            })
        }

        for pathModel in ArrFilePath {
            guard let pathModel = pathModel else {return}
            let op = BlockOperation {
                guard let path = pathModel.fileOriName else { return }
                self.handleImageWith(path: path, targetName: pathModel.showTargetName)
                self.finishCount += 1
            }
            finishOP.addDependency(op)
            multiThreadingQueue.addOperation(op)
        }
        multiThreadingQueue.addOperation(finishOP)
	}
    
	func handleImageWith(path:String ,targetName tName:String?) -> () {
        guard let image = NSImage(contentsOfFile: path) else { return }
        
        let size1x = ImageScaleTools.get1xSizeFrom(image: image, sourceRatio: sourceComboBox.indexOfSelectedItem+1)
        var handleIndex = 0
		
        for selectView in targetSelectItemsView.subviews {
            if selectView.isKind(of: NSButton.self) {
                let selectBotton = selectView as! NSButton
                if selectBotton.state == 1 && selectBotton.isEnabled {
                    guard let newimage = ImageScaleTools.creatScale(image: image, size1x: size1x, scaleRatio: selectView.tag) else { return }
					var oriImageName = ""
					var pathDirectory = ""
					if let targetName = tName{
						pathDirectory = (path as NSString).deletingLastPathComponent
						oriImageName = "\(targetName)@\(selectView.tag)x.png"
					}else{
						pathDirectory = (path as NSString).deletingPathExtension
						oriImageName = "@\(selectView.tag)x.png"
					}

                    var targetBasePath = ""
                    
                    var targetDirectoryNotExists = true
                    
                    let fm = FileManager.default
                    
                    var isDirectory:ObjCBool = true
                    
                    if fm.fileExists(atPath: targetDirectoryText.stringValue, isDirectory: &isDirectory) {
                        if isDirectory.boolValue {
                            targetBasePath = targetDirectoryText.stringValue
                            targetDirectoryNotExists = false
                        }
                    }
                    if targetDirectoryNotExists {
                        targetBasePath = targetDirectoryText.stringValue
                        guard let _ = try? fm.createDirectory(atPath: targetBasePath, withIntermediateDirectories: true, attributes: nil) else { return }
                    }
                    if let range = pathDirectory.range(of: basePathString) {
                        pathDirectory = pathDirectory.substring(from: range.upperBound)
                    }
                    
					var pathURL = URL(fileURLWithPath: targetBasePath, isDirectory: true, relativeTo: nil)

                    pathURL.appendPathComponent(pathDirectory)
                    guard let _ = try? fm.createDirectory(at: pathURL, withIntermediateDirectories: true, attributes: nil) else { return }
                    
                    
					pathURL.appendPathComponent(oriImageName)
                    
                    let oriImagePath = pathURL.path
					
                    ImageScaleTools.save(image: newimage, to: oriImagePath)
                    
                    
                    //MARK:	压缩图片
                    if enablePNGZipButton.state == 1 {
                        let newImageNames = ["-fs8","-or8"]
                        
                        var zipLevel = "50-100"
                        
                        switch PNGZipComboBox.indexOfSelectedItem {
                        case 0://低
                            zipLevel = "75-100"
                        case 1://中
                            zipLevel = "50-75"
                        case 2://高
                            zipLevel = "25-50"
                        case 2://自适应
                            zipLevel = "0-100"
                        default:
                            break
                        }
                        
                        pngquantTool.convertImage(path: oriImagePath, arguments: ["--quality=\(zipLevel)"])
                        
                        try? fm.removeItem(atPath: oriImagePath)
                        
                        pathURL.deletePathExtension()
                        for subfix in newImageNames {
                            let newImagePath = pathURL.path + subfix + ".png"
                            try? fm.moveItem(atPath: newImagePath, toPath: oriImagePath)
                        }
                    }
                    
                    
                    
					handleIndex += 1
					ArrFilePath[finishCount]?.progress = "\(handleIndex)/\(targetCount)"
					let rowIndexSet = NSIndexSet(index: finishCount) as IndexSet
					let columnIndexSet = NSIndexSet(index: 2) as IndexSet
                    
                    OperationQueue.main.addOperation({ 
                        self.tableview.reloadData(forRowIndexes: rowIndexSet, columnIndexes: columnIndexSet)
                    })
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
    
    @IBAction func sourceComboBoxDidSelected(_ sender: NSPopUpButton) {
		checkComboBox_SelectedButton(comboBoxIndex: sender.indexOfSelectedItem)
    }
	
	func checkComboBox_SelectedButton(comboBoxIndex:Int) -> () {
		for selectView in targetSelectItemsView.subviews {
			if selectView.isKind(of: NSButton.self) {
				let selectBotton = selectView as! NSButton
				
				selectBotton.isEnabled = selectBotton.tag-1 <= comboBoxIndex
			}
		}
	}
    
    
    @IBAction func clickSaveConfig(_ sender: NSButton) {
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
    
    
//MARK:	TextFieldSelector
    func textFieldDidChange(noti: NSNotification) -> () {
        let textField = noti.object as! NSTextField
        if textField == directoryText! {
            if FileManager.default.fileExists(atPath: directoryText.stringValue, isDirectory: nil) {
                ArrFilePath.removeAll()
                let _ = applyDirectoryText(pathStr: textField.stringValue)
                tableview.reloadData()
            }
        }
       
        
    }
    
//MARK:	NSTableViewDelegate
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        guard let text = fieldEditor.string else {print("false"); return true}
        
        if control == directoryText! {
            
        }else{
            if text == "" {
                return false
            }
            
            ArrFilePath[tableview.selectedRow]?.showTargetName = text
        }

        return true
    }
	
//MARK:	NSTableViewOtherSelecter

	func tableViewDidDoubleClick(tableview: NSTableView) -> () {
		if tableview.clickedColumn == 1 {
            
			tableview.editColumn(tableview.selectedColumn, row: tableview.selectedRow, with: nil, select: true)
		}else{
			guard let filePath = ArrFilePath[tableview.clickedRow]?.fileOriName else { return }
			if FileManager.default.isReadableFile(atPath: filePath) {
				NSWorkspace.shared().openFile(filePath)
			}
		}
	}
    
//MARK:	NSTextFieldDelegate

}

