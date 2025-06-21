//
//  AccountsViewController.swift
//  Lab9
//
//  Created by Елизавета Сенюк on 19.06.25.
//


import UIKit

class AccountsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()
    private var accounts: [Account] = []
    var user: UserData?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ваши счета"
        view.backgroundColor = .systemBackground
        setupTableView()
        loadAccountsFromDatabase()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAccount))
        print("Пользователь в AddAccountViewController: \(String(describing: user))")

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAccountsFromDatabase()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AccountCell")
    }
    @objc private func addAccount() {
        if let currentUser = UserData.loadCurrentUser() {
            print("Загружен пользователь: \(currentUser.login)")
            let addVC = AddAccountViewController()
            addVC.user = currentUser
            navigationController?.pushViewController(addVC, animated: true)
        } else {
            print("Пользователь не найден — нельзя добавить счёт")
            let alert = UIAlertController(title: "Ошибка", message: "Не удалось определить текущего пользователя", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
        }
    }
    private func loadAccountsFromDatabase() {
        if let user = UserData.loadCurrentUser() {
            print(" Загружен пользователь: \(user.login), \(user.email), \(user.password)")
            accounts = DatabaseManager.shared.fetchAccounts(forUserLogin: user.login)
            tableView.reloadData()
        } else {
            print("Пользователь не найден. Проверь сохранение или структуру.")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.filter { $0.isActive && !$0.isClosed }.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let activeAccounts = accounts.filter { $0.isActive && !$0.isClosed }
        let account = activeAccounts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)
        cell.textLabel?.text = "\(account.description): \(account.balance) BYR"
        cell.detailTextLabel?.text = account.isActive ? "Активен" : "Заблокирован"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activeAccounts = accounts.filter { $0.isActive && !$0.isClosed }
        let account = activeAccounts[indexPath.row]

        var message = "Баланс: \(account.balance) BYR\nСтатус: \(account.isActive ? "Активен" : "Заблокирован")"
        if account.type == .card, account.cardSubtype == .salary, let overdraft = account.overdraftLimit {
            message += "\nОвердрафт: \(overdraft) BYR"
        }

        let alert = UIAlertController(
            title: account.description,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
