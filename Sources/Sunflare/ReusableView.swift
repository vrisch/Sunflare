//
//  ReusableView.swift
//  Sunflare
//
//  Created by Magnus Nilsson on 2017-09-01.
//  Copyright © 2017 Sunflare. All rights reserved.
//

public protocol ReusableViewPresenter: class, ViewPresenter {
    func viewDidLoad(_ reusableView: ReusableView<Self>) throws
    func viewWillAppear(_ reusableView: ReusableView<Self>) throws
    func viewDidDisappear(_ reusableView: ReusableView<Self>) throws
    
    func viewDidFail(_ reusableView: ReusableView<Self>, error: Error)
    
    func mouseDown(point: CGPoint) throws -> Bool
    func mouseUp(point: CGPoint) throws -> Bool
}

public extension ReusableViewPresenter {
    func viewDidFail(_ reusableView: ReusableView<Self>, error: Error) {
    }
    func mouseDown(point: CGPoint) throws -> Bool {
        return false
    }
    func mouseUp(point: CGPoint) throws -> Bool {
        return false
    }
}

#if canImport(UIKit)
import UIKit

public class ReusableView<P: ReusableViewPresenter>: UIView {
    public var presenter: P? = nil {
        willSet {
            do {
                try presenter?.viewDidDisappear(self)
                subviews.forEach { $0.removeFromSuperview() }
            } catch let error {
                presenter?.viewDidFail(self, error: error)
            }
        }
        didSet {
            do {
                try presenter?.viewDidLoad(self)
                try presenter?.viewWillAppear(self)
            } catch let error {
                presenter?.viewDidFail(self, error: error)
            }
        }
    }
    
    deinit {
        do {
            try presenter?.viewDidDisappear(self)
        } catch let error {
            presenter?.viewDidFail(self, error: error)
        }
    }
}
#endif

#if canImport(Cocoa)
import Cocoa

public class ReusableView<P: ReusableViewPresenter>: NSView {
    public var presenter: P? = nil {
        willSet {
            do {
                try presenter?.viewDidDisappear(self)
                subviews.forEach { $0.removeFromSuperview() }
            } catch let error {
                presenter?.viewDidFail(self, error: error)
            }
        }
        didSet {
            do {
                try presenter?.viewDidLoad(self)
                try presenter?.viewWillAppear(self)
            } catch let error {
                presenter?.viewDidFail(self, error: error)
            }
        }
    }
    
    deinit {
        do {
            try presenter?.viewDidDisappear(self)
        } catch let error {
            presenter?.viewDidFail(self, error: error)
        }
    }
    
    public override var isFlipped: Bool { return true }
    
    public override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        do {
            if try presenter?.mouseDown(point: point) == false {
                super.mouseDown(with: event)
            }
        } catch let error {
            presenter?.viewDidFail(self, error: error)
        }
    }
    
    public override func mouseUp(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        do {
            if try presenter?.mouseUp(point: point) == false {
                super.mouseUp(with: event)
            }
        } catch let error {
            presenter?.viewDidFail(self, error: error)
        }
    }
}
#endif
