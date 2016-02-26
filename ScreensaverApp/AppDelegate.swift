//
//  AppDelegate.swift
//  ScreensaverApp
//
//  Created by Naman on 22/02/16.
//  Copyright © 2016 naman14. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow?
    
    lazy var screenSaverView = TerminalScreensaverView(frame: NSZeroRect, isPreview: false)


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let screenSaverView = screenSaverView {
            screenSaverView.frame = window!.contentView!.bounds;
            window!.contentView! = screenSaverView
            NSTimer.scheduledTimerWithTimeInterval(screenSaverView.animationTimeInterval, target: screenSaverView, selector: "animateOneFrame", userInfo: nil, repeats: true)

        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }

    @objc(didEndPref:returnCode:contextInfo:) private func didEndPref(sheet: NSWindow, returnCode: Int, contextInfo: UnsafeMutablePointer<Void>) {
        sheet.orderOut(self)
    }

	@IBAction func showPreferenceWindow(sender: AnyObject) {
        if let prefWin = screenSaverView?.configureSheet() {
            NSApp.beginSheet(prefWin, modalForWindow: window!, modalDelegate: self, didEndSelector: "didEndPref:returnCode:contextInfo:", contextInfo: nil)
        }
	}
}

