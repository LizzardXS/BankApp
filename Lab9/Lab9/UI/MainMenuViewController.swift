//
//  MainViewController.swift
//  Lab 8 t1
//
//  Created by Елизавета Сенюк on 19.06.25.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Главное меню"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        let accountsButton = UIButton(type: .system)
        accountsButton.setTitle("Просмотр счетов", for: .normal)
        accountsButton.accessibilityIdentifier = "accountsButton"
        accountsButton.addTarget(self, action: #selector(openAccounts), for: .touchUpInside)

        let converterButton = UIButton(type: .system)
        converterButton.setTitle("Конвертер валют", for: .normal)
        converterButton.accessibilityIdentifier = "converterButton"
        converterButton.addTarget(self, action: #selector(openConverter), for: .touchUpInside)

        let mapButton = UIButton(type: .system)
        mapButton.setTitle("Просмотр филиалов на карте", for: .normal)
        mapButton.accessibilityIdentifier = "mapButton"
        mapButton.addTarget(self, action: #selector(openMap), for: .touchUpInside)
        
        [accountsButton, converterButton, mapButton].forEach {
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            stack.addArrangedSubview($0)
        }

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func openAccounts() {
        if let nav = navigationController {
            if let accountsVC = nav.viewControllers.first(where: { $0 is AccountsViewController }) {
                nav.popToViewController(accountsVC, animated: true)
            } else {
                let accountsVC = AccountsViewController()
                nav.pushViewController(accountsVC, animated: true)
            }
        }
    }

    @objc func openConverter() {
        if let nav = navigationController {
            if let converterVC = nav.viewControllers.first(where: { $0 is CurrencyConverterViewController }) {
                nav.popToViewController(converterVC, animated: true)
            } else {
                let converterVC = CurrencyConverterViewController()
                nav.pushViewController(converterVC, animated: true)
            }
        }
    }
    
    @objc func openMap() {
        if let nav = navigationController {
            if let mapVC = nav.viewControllers.first(where: { $0 is MapViewController }) {
                nav.popToViewController(mapVC, animated: true)
            } else {
                let mapVC = MapViewController()
                nav.pushViewController(mapVC, animated: true)
            }
        }
    }
}
