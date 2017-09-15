//
//  ReusableView.swift
//  Sunflare
//
//  Created by Magnus Nilsson on 2017-09-01.
//  Copyright © 2017 Sunflare. All rights reserved.
//

#if os(OSX)
    import Cocoa
    public typealias View = NSView
#else
    import UIKit
    public typealias View = UIView
#endif

public protocol ReusableViewPresenter: class, ViewPresenter {
    weak var reusableView: ReusableView<Self>? { get set }
    
    func mouseDown(point: CGPoint) throws -> Bool
    func mouseUp(point: CGPoint) throws -> Bool
}

public extension ReusableViewPresenter {
    
    func mouseDown(point: CGPoint) throws -> Bool {
        return false
    }
    
    func mouseUp(point: CGPoint) throws -> Bool {
        return false
    }
}

public class ReusableView<P: ReusableViewPresenter>: View {
    public var presenter: P? = nil {
        willSet {
            do {
                try presenter?.viewDidDisappear()
                subviews.forEach { $0.removeFromSuperview() }
                presenter?.reusableView = nil
            } catch let error {
                presenter?.viewDidFail(error: error)
            }
        }
        didSet {
            do {
                presenter?.reusableView = self
                try presenter?.viewDidLoad()
                try presenter?.viewWillAppear()
            } catch let error {
                presenter?.viewDidFail(error: error)
            }
        }
    }
    
    deinit {
        do {
            try presenter?.viewDidDisappear()
        } catch let error {
            presenter?.viewDidFail(error: error)
        }
    }
    
    #if os(OSX)
    public override func mouseDown(with event: NSEvent) {
        if let presenter = presenter {
            let point = convert(event.locationInWindow, from: nil)
            do {
                guard try presenter.mouseDown(point: point) else { super.mouseDown(with: event) }
            } catch let error {
                presenter.viewDidFail(error: error)
            }
        }
    }
    
    public override func mouseUp(with event: NSEvent) {
        if let presenter = presenter {
            let point = convert(event.locationInWindow, from: nil)
            do {
                guard try presenter.mouseUp(point: point) else { super.mouseUp(with: event) }
            } catch let error {
                presenter.viewDidFail(error: error)
            }
        }
    }
    #endif
}