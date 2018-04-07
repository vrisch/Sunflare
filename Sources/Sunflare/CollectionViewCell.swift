//
//  CollectionViewCell.swift
//  Sunflare-iOS
//
//  Created by Vrisch on 2017-08-06.
//  Copyright © 2017 Sunflare. All rights reserved.
//

#if os(OSX) || os(watchOS)
#else
import UIKit

public protocol CollectionViewCellPresenter: class, ViewPresenter {
    func viewDidLoad(_ cell: CollectionViewCell<Self>, at: IndexPath) throws
    func viewWillAppear(_ cell: CollectionViewCell<Self>, at: IndexPath) throws
    func viewDidDisappear(_ cell: CollectionViewCell<Self>, at: IndexPath) throws
    
    func viewDidFail(_ cell: CollectionViewCell<Self>, at: IndexPath, error: Error)
}

public extension CollectionViewCellPresenter {
    func viewDidFail(_ cell: CollectionViewCell<Self>, at: IndexPath, error: Error) {
    }
}

public class CollectionViewCell<P: CollectionViewCellPresenter>: UICollectionViewCell {
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
                contentView.subviews.forEach { $0.removeFromSuperview() }
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

public extension CollectionViewCell {
    
    public var stackView: UIStackView {
        guard let stackView = contentView.subviews.first as? UIStackView else {
            let stackView = UIStackView(frame: .zero)
            if #available(iOS 11.0, *) {
                stackView.spacing = UIStackView.spacingUseSystem
            } else {
                stackView.spacing = 8
            }
            stackView.axis = .vertical
            contentView.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
                ])
            return stackView
        }
        return stackView
    }
}

#endif
