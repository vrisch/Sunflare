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
}
