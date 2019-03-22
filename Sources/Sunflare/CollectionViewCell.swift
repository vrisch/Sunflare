//
//  CollectionViewCell.swift
//  Sunflare-iOS
//
//  Created by Vrisch on 2017-08-06.
//  Copyright © 2017 Sunflare. All rights reserved.
//

#if canImport(UIKit)
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
    
    private var widthConstraint: NSLayoutConstraint? = nil
}

public extension CollectionViewCell {
    private enum Tags: Int {
        case stackViewTag = 90001
        case backgroundViewTag = 90002
    }
    
    var stackView: UIStackView {
        if let stackView = contentView.viewWithTag(Tags.stackViewTag.rawValue) {
            return stackView as! UIStackView
        } else {
            let stackView = UIStackView(frame: .zero)
            stackView.tag = Tags.stackViewTag.rawValue
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
    }
    
    func fixed(width: CGFloat) {
        if let _ = contentView.viewWithTag(Tags.backgroundViewTag.rawValue) {
            if widthConstraint?.constant != width {
                widthConstraint?.constant = width
            }
        } else {
            let backgroundView = UIView(frame: .zero)
            backgroundView.tag = Tags.backgroundViewTag.rawValue
            backgroundView.backgroundColor = .clear
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(backgroundView)
            contentView.sendSubviewToBack(backgroundView)
            widthConstraint = backgroundView.widthAnchor.constraint(equalToConstant: width)
            NSLayoutConstraint.activate([
                backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                backgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                widthConstraint!
                ])
        }
    }}
#endif
