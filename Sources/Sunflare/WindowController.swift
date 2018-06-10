//
//  WindowController.swift
//  Sunflare
//
//  Created by Magnus on 2018-06-10.
//  Copyright © 2018 Sunflare. All rights reserved.
//

#if canImport(Cocoa)
import Cocoa

public protocol WindowPresenter: Any, ViewPresenter {
    func windowDidBecomeKey(_ windowController: WindowController<Self>) throws
    
    func windowDidFail(_ windowController: WindowController<Self>, error: Error)
}

public extension WindowPresenter {
    func windowDidFail(_ windowController: WindowController<Self>, error: Error) {
    }
}

public class WindowController<P: WindowPresenter>: NSWindowController, NSWindowDelegate {
    let presenter: P
    
    public init?(presenter: P) {
        self.presenter = presenter
        super.init(window: NSWindow(contentRect: NSMakeRect(100, 100, NSScreen.main!.frame.width/2, NSScreen.main!.frame.height/2), styleMask: NSWindow.StyleMask(rawValue: (NSWindow.StyleMask.titled.rawValue | NSWindow.StyleMask.resizable.rawValue | NSWindow.StyleMask.miniaturizable.rawValue | NSWindow.StyleMask.closable.rawValue)), backing: NSWindow.BackingStoreType.buffered, defer: false))
        window?.delegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func windowDidBecomeKey(_ notification: Notification) {
        do {
            try presenter.windowDidBecomeKey(self)
        } catch let error {
            presenter.windowDidFail(self, error: error)
        }
    }
}
#endif
