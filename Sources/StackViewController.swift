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
        weak var stackView: NSStackView? { get set }
        weak var stackViewController: StackViewController<Self>? { get set }
        
        func configureStackView(_ stackView: NSStackView)
    }
    
    public extension StackViewPresenter {
        
        func configureStackView(_ stackView: NSStackView) {
        }
    }

    public class StackViewController<P: StackViewPresenter>: NSViewController {
        var stackView: NSStackView!
        let presenter: P
        
        public init?(presenter: P) {
            self.presenter = presenter
            super.init(nibName: nil, bundle: nil)
            presenter.stackViewController = self
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public override func loadView() {
            super.loadView()

            stackView = NSStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stackView)

            stackView.spacing = 0
            stackView.orientation = .vertical
            stackView.distribution = .fill
            presenter.configureStackView(stackView)
            
            presenter.stackView = stackView
            do {
                try presenter.viewDidLoad()
            } catch let error {
                presenter.viewDidFail(error: error)
            }

            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: view.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
        }
      
        public override func viewWillAppear() {
            super.viewWillAppear()
            do {
                try presenter.viewWillAppear()
            } catch let error {
                presenter.viewDidFail(error: error)
            }
        }

        public override func viewDidDisappear() {
            super.viewDidDisappear()
            do {
                try presenter.viewDidDisappear()
            } catch let error {
                presenter.viewDidFail(error: error)
            }
        }
    }

#else
    import UIKit

    public protocol StackViewPresenter: class, ViewPresenter {
        weak var stackView: UIStackView? { get set }
        weak var stackViewController: StackViewController<Self>? { get set }
        
        func configureStackView(_ stackView: UIStackView, traitCollection: UITraitCollection)
    }
    
    public extension StackViewPresenter {
        
        func configureStackView(_ stackView: UIStackView, traitCollection: UITraitCollection) {
        }
    }
    
    public class StackViewController<P: StackViewPresenter>: UIViewController {
        var stackView: UIStackView!
        let presenter: P
        let statusBarStyle: UIStatusBarStyle
        
        public init(presenter: P, statusBarStyle: UIStatusBarStyle = .default) {
            self.presenter = presenter
            self.statusBarStyle = statusBarStyle
            super.init(nibName: nil, bundle: nil)
            presenter.stackViewController = self
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
            
            presenter.stackView = stackView
            do {
                try presenter.viewDidLoad()
            } catch let error {
                presenter.viewDidFail(error: error)
            }
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: view.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
        }
        
        public override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            do {
                try presenter.viewWillAppear()
            } catch let error {
                presenter.viewDidFail(error: error)
            }
        }
        
        public override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            do {
                try presenter.viewDidDisappear()
            } catch let error {
                presenter.viewDidFail(error: error)
            }
        }
        
        public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            presenter.configureStackView(stackView, traitCollection: traitCollection)
        }
        
        public override var preferredStatusBarStyle: UIStatusBarStyle {
            return statusBarStyle
        }
    }
    
#endif
