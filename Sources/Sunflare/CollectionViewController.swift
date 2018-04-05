//
//  CollectionViewController.swift
//  Sunflare-iOS
//
//  Created by Magnus Nilsson on 2017-06-17.
//  Copyright © 2017 Sunflare. All rights reserved.
//

#if os(OSX) || os(watchOS)
#else
    import UIKit
    
    public protocol CollectionViewPresenter: class, ViewPresenter {
        func viewDidLoad(_ collectionViewController: CollectionViewController<Self>) throws
        func viewWillAppear(_ collectionViewController: CollectionViewController<Self>) throws
        func viewDidDisappear(_ collectionViewController: CollectionViewController<Self>) throws

        func viewDidFail(_ collectionViewController: CollectionViewController<Self>, error: Error)

        func configureLayout(_ layout: UICollectionViewFlowLayout)
        func numberOfItemsInSection(_ section: Int) -> Int
        func cellForItemAt(indexPath: IndexPath) -> UICollectionViewCell
        
        func selectItemAt(indexPath: IndexPath) throws
        func deselectItemAt(indexPath: IndexPath) throws
        
        func keyCommands() -> [(input: String, modifierFlags: UIKeyModifierFlags, discoverabilityTitle: String)]
        func handleKeyCommand(input: String) throws
    }
    
    public extension CollectionViewPresenter {
        func viewDidFail(_ collectionViewController: CollectionViewController<Self>, error: Error) {
        }
        func selectItemAt(indexPath: IndexPath) throws {
        }
        func deselectItemAt(indexPath: IndexPath) throws {
        }
        func keyCommands() -> [(input: String, modifierFlags: UIKeyModifierFlags, discoverabilityTitle: String)] {
            return []
        }
        func handleKeyCommand(input: String) throws {
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
            #if os(iOS)
                if #available(iOS 11.0, *) {
                    layout.sectionInsetReference = .fromSafeArea
                }
            #endif

            presenter.configureLayout(layout)

            super.init(collectionViewLayout: layout)
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func loadView() {
            super.loadView()
            
            edgesForExtendedLayout = []
            collectionView?.backgroundColor = .white
            
            do {
                try presenter.viewDidLoad(self)
            } catch let error {
                presenter.viewDidFail(self, error: error)
            }
        }
        
        public override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            do {
                try presenter.viewWillAppear(self)
            } catch let error {
                presenter.viewDidFail(self, error: error)
            }
            
        }
        
        public override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            do {
                try presenter.viewDidDisappear(self)
            } catch let error {
                presenter.viewDidFail(self, error: error)
            }
        }
        
        public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return presenter.numberOfItemsInSection(section)
        }
        
        public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            return presenter.cellForItemAt(indexPath: indexPath)
        }
        
        public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            becomeFirstResponder()
            do {
                try presenter.selectItemAt(indexPath: indexPath)
            } catch let error {
                presenter.viewDidFail(self, error: error)
            }
        }
        
        public override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
            do {
                try presenter.deselectItemAt(indexPath: indexPath)
            } catch let error {
                presenter.viewDidFail(self, error: error)
            }
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
            do {
                try presenter.handleKeyCommand(input: sender.input!)
            } catch let error {
                presenter.viewDidFail(self, error: error)
            }
        }
    }
#endif