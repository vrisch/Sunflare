//
//  CollectionReusableView.swift
//  Sunflare
//
//  Created by Magnus on 2018-06-17.
//  Copyright © 2018 Sunflare. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public protocol CollectionReusableViewPresenter: class, ViewPresenter {
    func viewDidLoad(_ reusableView: CollectionReusableView<Self>, at: IndexPath) throws
    func viewWillAppear(_ reusableView: CollectionReusableView<Self>, at: IndexPath) throws
    func viewDidDisappear(_ reusableView: CollectionReusableView<Self>, at: IndexPath) throws
    
    func viewDidFail(_ reusableView: CollectionReusableView<Self>, at: IndexPath, error: Error)
}

public extension CollectionReusableViewPresenter {
    func viewDidFail(_ reusableView: CollectionReusableView<Self>, at: IndexPath, error: Error) {
    }
}

public class CollectionReusableView<P: CollectionReusableViewPresenter>: UICollectionReusableView {
    var presenter: P? = nil
    var indexPath: IndexPath? = nil
    
    public func load(presenter newPresenter: P, at: IndexPath) {
        unload()
        presenter = newPresenter
        indexPath = at
        if let presenter = presenter, let indexPath = indexPath {
            do {
                try presenter.viewDidLoad(self, at: indexPath)
                try presenter.viewWillAppear(self, at: indexPath)
            } catch let error {
                presenter.viewDidFail(self, at: indexPath, error: error)
            }
        }
    }
    
    public func unload() {
        if let presenter = presenter, let indexPath = indexPath {
            do {
                subviews.forEach { $0.removeFromSuperview() }
                try presenter.viewDidDisappear(self, at: indexPath)
            } catch let error {
                presenter.viewDidFail(self, at: indexPath, error: error)
            }
        }
    }
    
    deinit {
        unload()
    }
}

public extension CollectionReusableView {
    
    public var stackView: UIStackView {
        guard let stackView = subviews.first as? UIStackView else {
            let stackView = UIStackView(frame: .zero)
            if #available(iOS 11.0, *) {
                stackView.spacing = UIStackView.spacingUseSystem
            } else {
                stackView.spacing = 8
            }
            stackView.axis = .vertical
            addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
                ])
            return stackView
        }
        return stackView
    }
}

#endif
