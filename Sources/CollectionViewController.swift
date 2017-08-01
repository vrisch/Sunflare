//
//  CollectionViewController.swift
//  Sunflare-iOS
//
//  Created by Magnus Nilsson on 2017-06-17.
//  Copyright © 2017 Sunflare. All rights reserved.
//

import Foundation
import UIKit

public protocol CollectionViewCellPresenter: class, ViewPresenter {
    var indexPath: IndexPath { get set }
    weak var cell: UICollectionViewCell? { get set }
}

public class CollectionViewCell<P: CollectionViewCellPresenter>: UICollectionViewCell {
    public var presenter: P? = nil {
        didSet {
            reset()
            presenter?.cell = self
            presenter?.viewDidLoad()
            presenter?.viewWillAppear()
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
    
    private func reset() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }
}

public protocol CollectionViewPresenter: class, ViewPresenter {
    weak var collectionView: UICollectionView? { get set }
    
    func configureLayout(_ layout: UICollectionViewFlowLayout)
    func numberOfItemsInSection(_ section: Int) -> Int
    func cellForItemAt(indexPath: IndexPath) -> UICollectionViewCell
    
    func selectItemAt(indexPath: IndexPath)
    func deselectItemAt(indexPath: IndexPath)
    
    func keyCommands() -> [(input: String, modifierFlags: UIKeyModifierFlags, discoverabilityTitle: String)]
    func handleKeyCommand(input: String)
}

public extension CollectionViewPresenter {
    
    func selectItemAt(indexPath: IndexPath) {
    }
    
    func deselectItemAt(indexPath: IndexPath) {
    }
    
    func keyCommands() -> [(input: String, modifierFlags: UIKeyModifierFlags, discoverabilityTitle: String)] {
        return []
    }
    func handleKeyCommand(input: String) {
    }
}

public class CollectionViewController<P: CollectionViewPresenter>: UICollectionViewController {
    let presenter: P
    
    public init(presenter: P) {
        self.presenter = presenter
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        presenter.configureLayout(layout)
        
        super.init(collectionViewLayout: layout)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var navigationItem: UINavigationItem {
        let navigationItem = super.navigationItem
        presenter.configureNavigationItem(navigationItem)
        return navigationItem
    }

    public override func loadView() {
        super.loadView()
        
        edgesForExtendedLayout = []
        collectionView?.backgroundColor = .white
        
        presenter.collectionView = collectionView
        presenter.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
    }
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfItemsInSection(section)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return presenter.cellForItemAt(indexPath: indexPath)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        becomeFirstResponder()
        presenter.selectItemAt(indexPath: indexPath)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        presenter.deselectItemAt(indexPath: indexPath)
    }
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    public override var keyCommands: [UIKeyCommand]? {
        let commands = presenter.keyCommands()
        guard commands.count > 0 else { return nil }
        return commands.map { let (input, modifierFlags, discoverabilityTitle) = $0;
            return UIKeyCommand(input: input, modifierFlags: modifierFlags, action: #selector(handleKeyCommand(sender:)), discoverabilityTitle: discoverabilityTitle)
        }
    }
    
    @objc private func handleKeyCommand(sender: UIKeyCommand) {
        presenter.handleKeyCommand(input: sender.input!)
    }
}
