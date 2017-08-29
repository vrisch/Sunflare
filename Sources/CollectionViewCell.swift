//
//  CollectionViewCell.swift
//  Sunflare-iOS
//
//  Created by Vrisch on 2017-08-06.
//  Copyright © 2017 Sunflare. All rights reserved.
//

import UIKit

public protocol CollectionViewCellPresenter: class, ViewPresenter {
    var indexPath: IndexPath { get set }
    weak var cell: UICollectionViewCell? { get set }
    weak var collectionViewController: UICollectionViewController? { get set }
}

public class CollectionViewCell<P: CollectionViewCellPresenter>: UICollectionViewCell {
    public var presenter: P? = nil {
        didSet {
            do {
                try oldValue?.viewDidDisappear()
                contentView.subviews.forEach { $0.removeFromSuperview() }
                
                presenter?.cell = self
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
