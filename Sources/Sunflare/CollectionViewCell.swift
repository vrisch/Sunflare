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
    
    public lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        if #available(iOS 11.0, *) {
            stackView.spacing = UIStackView.spacingUseSystem
        } else {
            stackView.spacing = 8
        }
        stackView.axis = .vertical
        contentView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: contentView.topAnchor),
            bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        return stackView
    }()
    
    public func load(presenter p: P, at ip: IndexPath) {
        if let presenter = presenter, let indexPath = indexPath {
            do {
                try presenter.viewDidDisappear(self, at: indexPath)
                contentView.subviews.forEach { $0.removeFromSuperview() }
            } catch let error {
                presenter.viewDidFail(self, at: indexPath, error: error)
            }
        }
        presenter = p
        indexPath = ip
        if let presenter = presenter, let indexPath = indexPath {
            do {
                try presenter.viewDidLoad(self, at: indexPath)
                try presenter.viewWillAppear(self, at: indexPath)
            } catch let error {
                presenter.viewDidFail(self, at: indexPath, error: error)
            }
        }
    }
    
    deinit {
        if let presenter = presenter, let indexPath = indexPath {
            do {
                try presenter.viewDidDisappear(self, at: indexPath)
            } catch let error {
                presenter.viewDidFail(self, at: indexPath, error: error)
            }
        }
    }
}
#endif
