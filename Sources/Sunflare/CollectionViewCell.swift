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
    func viewDidLoad(_ cell: UICollectionViewCell) throws
    func viewWillAppear(_ cell: UICollectionViewCell) throws
    func viewDidDisappear(_ cell: UICollectionViewCell) throws
    
    func viewDidFail(_ cell: UICollectionViewCell, error: Error)
}

public extension CollectionViewCellPresenter {
    func viewDidFail(_ cell: UICollectionViewCell, error: Error) {
    }
}

public class CollectionViewCell<P: CollectionViewCellPresenter>: UICollectionViewCell {
    public var presenter: P? = nil {
        willSet {
            do {
                try presenter?.viewDidDisappear(self)
                contentView.subviews.forEach { $0.removeFromSuperview() }
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
