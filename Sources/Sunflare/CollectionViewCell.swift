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

    func load(presenter p: P, at ip: IndexPath) {
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
