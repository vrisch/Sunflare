//
//  CollectionViewController.swift
//  Sunflare-iOS
//
//  Created by Magnus Nilsson on 2017-06-17.
//  Copyright © 2017 Sunflare. All rights reserved.
//

import Foundation
import UIKit

protocol CollectionViewPresenter: class, ViewPresenter {
    weak var collectionView: UICollectionView? { get set }
    
    func configureLayout(_ layout: UICollectionViewFlowLayout)
    func numberOfItemsInSection(_ section: Int) -> Int
    func cellForItemAt(indexPath: IndexPath) -> UICollectionViewCell
    
    func selectItemAt(indexPath: IndexPath)
    func deselectItemAt(indexPath: IndexPath)
    
    func keyCommands() -> [(input: String, modifierFlags: UIKeyModifierFlags, discoverabilityTitle: String)]
    func handleKeyCommand(input: String)
}

extension CollectionViewPresenter {
    
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

class CollectionViewController<P: CollectionViewPresenter>: UICollectionViewController {
    let presenter: P
    
    init(presenter: P) {
        self.presenter = presenter
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        presenter.configureLayout(layout)
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        edgesForExtendedLayout = []
        collectionView?.backgroundColor = .white
        
        presenter.collectionView = collectionView
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfItemsInSection(section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return presenter.cellForItemAt(indexPath: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        becomeFirstResponder()
        presenter.selectItemAt(indexPath: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        presenter.deselectItemAt(indexPath: indexPath)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var keyCommands: [UIKeyCommand]? {
        let commands = presenter.keyCommands()
        guard commands.count > 0 else { return nil }
        return commands.map { let (input, modifierFlags, discoverabilityTitle) = $0;
            return UIKeyCommand(input: input, modifierFlags: modifierFlags, action: #selector(handleKeyCommand(sender:)), discoverabilityTitle: discoverabilityTitle)
        }
    }
    
    @objc func handleKeyCommand(sender: UIKeyCommand) {
        presenter.handleKeyCommand(input: sender.input!)
    }
}
