//
//  StackViewController.swift
//  Sunflare-iOS
//
//  Created by Magnus Nilsson on 2017-06-19.
//  Copyright © 2017 Sunflare. All rights reserved.
//

#if os(OSX)
    import Cocoa
    
    public protocol StackViewPresenter: class, ViewPresenter {
        func viewDidLoad(_ stackViewController: StackViewController<Self>) throws
        func viewWillAppear(_ stackViewController: StackViewController<Self>) throws
        func viewDidDisappear(_ stackViewController: StackViewController<Self>) throws
        
        func viewDidFail(_ stackViewController: StackViewController<Self>, error: Error)

        func configureStackView(_ stackView: NSStackView)
    }
    
    public extension StackViewPresenter {
        func viewDidFail(_ stackViewController: StackViewController<Self>, error: Error) {
        }
        func configureStackView(_ stackView: NSStackView) {
        }
    }

    public class StackViewController<P: StackViewPresenter>: NSViewController {
        public var stackView: NSStackView!
        let presenter: P
        
        public init?(presenter: P) {
            self.presenter = presenter
            super.init(nibName: nil, bundle: nil)
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func loadView() {
            view = NSView(frame: NSRect(x: 50, y: 50, width: 480, height: 320))
        }
        
        public override func viewDidLoad() {
            stackView = NSStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stackView)
            
            stackView.spacing = 0
            stackView.orientation = .vertical
            if #available(OSX 10.11, *) {
                stackView.distribution = .fill
            }
            presenter.configureStackView(stackView)
            
            do {
                try presenter.viewDidLoad(self)
            } catch let error {
                presenter.viewDidFail(self, error: error)
            }
            
            if #available(OSX 10.11, *) {
                NSLayoutConstraint.activate([
                    stackView.topAnchor.constraint(equalTo: view.topAnchor),
                    stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                    ])
            }
        }
        
        public override func viewWillAppear() {
            super.viewWillAppear()
            do {
                try presenter.viewWillAppear(self)
            } catch let error {
                presenter.viewDidFail(self, error: error)
            }
        }
        
        public override func viewDidDisappear() {
            super.viewDidDisappear()
            do {
                try presenter.viewDidDisappear(self)
            } catch let error {
                presenter.viewDidFail(self, error: error)
            }
        }
    }
    
#elseif os(iOS) || os(tvOS)
    import UIKit
    
    public protocol StackViewPresenter: class, ViewPresenter {
        func viewDidLoad(_ stackViewController: StackViewController<Self>) throws
        func viewWillAppear(_ stackViewController: StackViewController<Self>) throws
        func viewDidDisappear(_ stackViewController: StackViewController<Self>) throws
        
        func viewDidFail(_ stackViewController: StackViewController<Self>, error: Error)
        
        func configureStackView(_ stackView: UIStackView, traitCollection: UITraitCollection)
    }
    
    public extension StackViewPresenter {
        func viewDidFail(_ stackViewController: StackViewController<Self>, error: Error) {
        }
        func configureStackView(_ stackView: UIStackView, traitCollection: UITraitCollection) {
        }
    }

    public class StackViewController<P: StackViewPresenter>: UIViewController {
        public var stackView: UIStackView!
        let presenter: P

        public init(presenter: P) {
            self.presenter = presenter
            super.init(nibName: nil, bundle: nil)
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func loadView() {
            super.loadView()
            
            edgesForExtendedLayout = []
            view.backgroundColor = .white
            
            stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stackView)
            
            stackView.spacing = 0
            stackView.axis = .vertical
            stackView.distribution = .fill
            presenter.configureStackView(stackView, traitCollection: traitCollection)
            
            do {
                try presenter.viewDidLoad(self)
            } catch let error {
                presenter.viewDidFail(self, error: error)
            }
            
            func normalContraints() {
                NSLayoutConstraint.activate([
                    stackView.topAnchor.constraint(equalTo: view.topAnchor),
                    stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                    ])
            }
            
            #if os(iOS)
                if #available(iOS 11.0, *) {
                    NSLayoutConstraint.activate([
                        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                        stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                        stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
                        ])
                } else {
                    normalContraints()
                }
            #else
                normalContraints()
            #endif
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
        
        public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            presenter.configureStackView(stackView, traitCollection: traitCollection)
        }
    }
#endif
