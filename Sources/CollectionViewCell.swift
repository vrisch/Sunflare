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
            oldValue?.viewDidDisappear()
            contentView.subviews.forEach { $0.removeFromSuperview() }
            
            presenter?.cell = self
            presenter?.viewDidLoad()
            presenter?.viewWillAppear()
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil // This will make viewDidDisappear to be callled
    }
    
    deinit {
        presenter?.viewDidDisappear()
    }
}
