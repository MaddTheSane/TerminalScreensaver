//
//  TerminalScreensaverView.swift
//  TerminalScreensaver
//
//  Created by Naman on 22/02/16.
//  Copyright © 2016 naman14. All rights reserved.
//

import Cocoa

import ScreenSaver

class TerminalScreensaverView: ScreenSaverView {
    
    private var nibArray: NSArray? = nil
    
    var defaults: NSUserDefaults
    
    private var terminalColor: NSColor?
    private var terminalTextColor: NSColor?
    private var lineDelay: Double = 0.2
    private var fontSize: Double = 12
    private var repeatEnabled: Bool = true
    
    @IBOutlet weak var configSheet: NSWindow! = nil
    @IBOutlet weak var textConfigSheet: NSWindow! = nil
    @IBOutlet weak var terminalColorWell: NSColorWell?
    @IBOutlet weak var terminalTextColorWell: NSColorWell?
    @IBOutlet weak var lineDelaySlider: NSSlider?
    @IBOutlet weak var lineDelaySliderLabel: NSTextField?
    @IBOutlet weak var fontSizeSlider: NSSlider?
    @IBOutlet weak var isRepeatEnabledButton: NSButton?
    
    private var textLabel: NSTextView?
    private var scrollView: NSScrollView?
    
    private var list: [String] = []
    private var readPosition: Int = 0
    
    @IBAction func applyClick(button: NSButton)
    {
        NSApp.endSheet(configSheet!)
    }
    
    @IBAction func backgroundColorClick(button: NSColorWell)
    {
        terminalColorPreference = terminalColorWell!.color
    }
    @IBAction func terminalTextColorClick(button: NSColorWell)
    {
        terminalTextColorPreference = terminalTextColorWell!.color
    }
    
    @IBAction func cancelClick(button: NSButton)
    {
        NSApp.endSheet(configSheet!)
    }
    
    @IBAction func isRepeatStateChange(button: NSButton)
    {
        if(button.state == NSOnState) {
            repeatEnabledPreference = true
            repeatEnabled = true
        }
        else {
            repeatEnabledPreference = false
            repeatEnabled = false
        }
    }
    @IBAction func lineDelaySliderChange(slider: NSSlider)
    {
        lineDelayPreference = slider.doubleValue
        lineDelaySliderLabel?.stringValue = String(format:"%.2f", slider.doubleValue) + " seconds"
    }
    @IBAction func fontSizeSliderChange(slider: NSSlider)
    {
        fontSizePreference = slider.doubleValue
    }
    
    override func drawRect(dirtyRect: NSRect) {
        
    }
    
    override init?(frame: NSRect, isPreview: Bool) {
        let identifier = NSBundle(forClass: TerminalScreensaverView.self).bundleIdentifier!
        defaults = ScreenSaverDefaults(forModuleWithName: identifier)!
        
        super.init(frame: frame, isPreview: isPreview)
        initialise()
        readTerminalTextFile()
    }
    
    required init?(coder: NSCoder) {
        let identifier = NSBundle(forClass: TerminalScreensaverView.self).bundleIdentifier!
        defaults = ScreenSaverDefaults(forModuleWithName: identifier)!
        
        super.init(coder: coder)
        initialise()
        readTerminalTextFile()
        
    }
    
    private func initialise() {
        
        terminalColor = terminalColorPreference
        terminalTextColor = terminalTextColorPreference
        lineDelay = lineDelayPreference
        fontSize = fontSizePreference
        repeatEnabled = repeatEnabledPreference
        
        scrollView = NSScrollView(frame: bounds)
        scrollView?.hasVerticalScroller = true
        scrollView?.hasHorizontalScroller = false
        scrollView?.backgroundColor = terminalColor!
        
        scrollView?.autoresizingMask = NSAutoresizingMaskOptions([.ViewWidthSizable,.ViewHeightSizable]);
        let contentSize: NSSize = (scrollView?.contentSize)!
        
        textLabel = NSTextView(frame: NSMakeRect(0, 0, contentSize.width, contentSize.height))
        textLabel?.minSize = NSMakeSize(0.0, contentSize.height)
        textLabel?.maxSize = NSMakeSize(CGFloat(FLT_MAX), CGFloat(FLT_MAX))
        textLabel?.verticallyResizable = true
        textLabel?.horizontallyResizable = false
        textLabel!.autoresizingMask = NSAutoresizingMaskOptions([.ViewWidthSizable]);
        textLabel?.textContainer?.containerSize = NSMakeSize(contentSize.width, CGFloat(FLT_MAX))
        textLabel?.textContainer?.widthTracksTextView = true
        textLabel!.translatesAutoresizingMaskIntoConstraints = false
        textLabel!.editable = false
        textLabel!.drawsBackground = false
        textLabel!.selectable = false
        
        scrollView?.documentView = textLabel
        
        addSubview(scrollView!)
        
        animationTimeInterval = lineDelay
        
    }
    
    
    private func readTerminalTextFile() {
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
            
            let path = dir.stringByAppendingPathComponent("terminalscreensaver.txt");
            let checkValidation = NSFileManager.defaultManager()
            
            if (checkValidation.fileExistsAtPath(path)) {
                if let aStreamReader = StreamReader(path: path) {
                    defer {
                        aStreamReader.close()
                    }
                    while let line = aStreamReader.nextLine() {
                        list.append(line)
                    }
                }
            } else {
                readTerminalTextFromBundle()
            }
            
        } else {
            readTerminalTextFromBundle()
        }
        
        
    }
    
    private func readTerminalTextFromBundle() {
        let bundle = NSBundle(forClass: TerminalScreensaverView.self)
        let path = bundle.URLForResource("terminalscreensaver", withExtension: "txt")
        if let aStreamReader = StreamReader(URL: path!) {
            defer {
                aStreamReader.close()
            }
            while let line = aStreamReader.nextLine() {
                list.append(line)
            }
        }
        
    }
    
    override func startAnimation() {
        super.startAnimation()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    override func animateOneFrame() {
        
        if(readPosition < list.count) {
            append(list[readPosition])
            append("\n")
            readPosition+=1
        } else if repeatEnabled {
            readPosition = 0
        }
        
    }
    
    override func hasConfigureSheet() -> Bool {
        return true
    }
    
    override func configureSheet() -> NSWindow? {
        if configSheet == nil {
            let ourBundle = NSBundle(forClass: self.dynamicType)
            ourBundle.loadNibNamed("PreferenceWindow", owner: self, topLevelObjects: &nibArray)
            terminalColorWell!.color = terminalColorPreference
            terminalTextColorWell!.color = terminalTextColorPreference
            lineDelaySlider?.doubleValue = lineDelayPreference
            lineDelaySliderLabel?.stringValue =  String(format:"%.2f", lineDelay) + " seconds"
            fontSizeSlider?.doubleValue = fontSizePreference
            
            if repeatEnabledPreference {
                isRepeatEnabledButton?.state = NSOnState
            } else {
                isRepeatEnabledButton?.state = NSOffState
            }
        }
        return configSheet
    }
    
    
    func append(string: String) {
        let textView = scrollView?.documentView as! NSTextView
        let attributedString = NSMutableAttributedString(string: string)
        let range = NSMakeRange(0, (string as NSString).length)
        attributedString.addAttribute(NSForegroundColorAttributeName , value:terminalTextColor!,range: range)
        attributedString.addAttribute(NSFontAttributeName, value: NSFont.systemFontOfSize(CGFloat(fontSize)), range: range)
        textView.textStorage?.appendAttributedString(attributedString)
        textView.scrollToEndOfDocument(nil)
    }
    
    
    var terminalColorPreference: NSColor {
        set(newColor) {
            defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(newColor), forKey: "terminalColor")
            defaults.synchronize()
        }
        get {
            if let terminalColorData = defaults.objectForKey("terminalColor") as? NSData {
                return (NSKeyedUnarchiver.unarchiveObjectWithData(terminalColorData) as? NSColor)!
            }
            else {
                return NSColor.blackColor()
            }
        }
    }
    
    var terminalTextColorPreference: NSColor {
        set(newColor) {
            defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(newColor), forKey: "terminalTextColor")
            defaults.synchronize()
        }
        get {
            if let terminalColorData = defaults.objectForKey("terminalTextColor") as? NSData {
                return (NSKeyedUnarchiver.unarchiveObjectWithData(terminalColorData) as? NSColor)!
            }
            else {
                return NSColor.whiteColor()
            }
        }
    }
    
    var terminalTextPreference: String {
        set(newValue) {
            defaults.setObject(newValue, forKey: "terminalText")
            defaults.synchronize()
        }
        get {
            if let terminaltextData = defaults.stringForKey("terminalText") {
                return terminaltextData
            }
            else {
                return "This is a lol string"
            }
        }
    }
    
    var lineDelayPreference: Double {
        set(newValue) {
            defaults.setDouble(newValue, forKey: "lineDelayTime")
            defaults.synchronize()
        }
        get {
            return defaults.doubleForKey("lineDelayTime")
        }
    }
    
    var fontSizePreference: Double {
        set(newValue) {
            defaults.setDouble(newValue, forKey: "textFontSize")
            defaults.synchronize()
        }
        get {
            return defaults.doubleForKey("textFontSize")
        }
    }
    
    var repeatEnabledPreference: Bool {
        set(newValue) {
            defaults.setBool(newValue, forKey: "isRepeatEnabled")
            defaults.synchronize()
        }
        get {
            return defaults.boolForKey("isRepeatEnabled")
        }
    }
    
    class StreamReader  {
        
        let encoding : UInt
        let chunkSize : Int
        
        var fileHandle : NSFileHandle!
        let buffer : NSMutableData!
        let delimData : NSData!
        var atEof : Bool = false
        
        init?(URL: NSURL, delimiter: String = "\n", encoding : NSStringEncoding = NSUTF8StringEncoding, chunkSize : Int = 4096) {
            self.chunkSize = chunkSize
            self.encoding = encoding
            
            if let fileHandle = try? NSFileHandle(forReadingFromURL: URL),
                delimData = delimiter.dataUsingEncoding(encoding),
                buffer = NSMutableData(capacity: chunkSize)
            {
                self.fileHandle = fileHandle
                self.delimData = delimData
                self.buffer = buffer
            } else {
                self.fileHandle = nil
                self.delimData = nil
                self.buffer = nil
                return nil
            }
        }

        convenience init?(path: String, delimiter: String = "\n", encoding : NSStringEncoding = NSUTF8StringEncoding, chunkSize : Int = 4096) {
            self.init(URL: NSURL(fileURLWithPath: path), delimiter: delimiter, encoding: encoding, chunkSize: chunkSize)
        }
        
        deinit {
            self.close()
        }
        
        /// Return next line, or nil on EOF.
        func nextLine() -> String? {
            precondition(fileHandle != nil, "Attempt to read from closed file")
            
            if atEof {
                return nil
            }
            
            // Read data chunks from file until a line delimiter is found:
            var range = buffer.rangeOfData(delimData, options: [], range: NSMakeRange(0, buffer.length))
            while range.location == NSNotFound {
                let tmpData = fileHandle.readDataOfLength(chunkSize)
                if tmpData.length == 0 {
                    // EOF or read error.
                    atEof = true
                    if buffer.length > 0 {
                        // Buffer contains last line in file (not terminated by delimiter).
                        let line = String(data: buffer, encoding: encoding)
                        
                        buffer.length = 0
                        return line
                    }
                    // No more lines.
                    return nil
                }
                buffer.appendData(tmpData)
                range = buffer.rangeOfData(delimData, options: [], range: NSMakeRange(0, buffer.length))
            }
            
            // Convert complete line (excluding the delimiter) to a string:
            let line = String(data: buffer.subdataWithRange(NSMakeRange(0, range.location)),
                encoding: encoding)
            // Remove line (and the delimiter) from the buffer:
            buffer.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
            
            return line
        }
        
        /// Start reading from the beginning of file.
        func rewind() -> Void {
            fileHandle.seekToFileOffset(0)
            buffer.length = 0
            atEof = false
        }
        
        /// Close the underlying file. No reading must be done after calling this method.
        func close() -> Void {
            fileHandle?.closeFile()
            fileHandle = nil
        }
    }
}
