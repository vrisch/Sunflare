//
//  StackViewController.swift
//  Sunflare-iOS
//
//  Created by Magnus Nilsson on 2017-06-19.
//  Copyright © 2017 Sunflare. All rights reserved.
//

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
    
    public init(presenter: P) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        presenter.stackViewController = self
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
        view.backgroundColor = .white
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.distribution = .fill
        presenter.configureStackView(stackView, traitCollection: traitCollection)

        presenter.stackView = stackView
        presenter.viewDidLoad()
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
    }
}

