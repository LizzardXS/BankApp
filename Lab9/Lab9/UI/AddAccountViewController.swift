//
//  AddAccountViewController.swift
//  Lab 8 t1
//
//  Created by Елизавета Сенюк on 19.06.25.
//

import UIKit

class AddAccountViewController: UIViewController {

    private let accountTypes: [AccountType] = [.current, .savings, .credit, .card]
    private let cardSubtypes: [CardSubtype] = [.salary, .savings, .credit]

    private let typePicker = UIPickerView()
    private let subtypePicker = UIPickerView()

    private var selectedAccountType: AccountType = .current
    private var selectedCardSubtype: CardSubtype?

    private let balanceField = UITextField()
    private let overdraftField = UITextField()
    private let isActiveSwitch = UISwitch()
    private let saveButton = UIButton(type: .system)
    var user: UserData!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Добавить счёт"
        view.backgroundColor = .systemBackground
        setupUI()
        
        subtypePicker.isHidden = selectedAccountType != .card
        overdraftField.isHidden = true
    }

    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        let typeLabel = UILabel()
        typeLabel.text = "Тип счёта"
        typePicker.delegate = self
        typePicker.dataSource = self

        let subtypeLabel = UILabel()
        subtypeLabel.text = "Подтип (если карт-счёт)"
        subtypePicker.delegate = self
        subtypePicker.dataSource = self

        balanceField.placeholder = "Баланс"
        balanceField.borderStyle = .roundedRect
        balanceField.keyboardType = .decimalPad

        overdraftField.placeholder = "Овердрафт (если зарплатный)"
        overdraftField.borderStyle = .roundedRect
        overdraftField.keyboardType = .decimalPad

        let statusLabel = UILabel()
        statusLabel.text = "Счёт активен?"

        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.addTarget(self, action: #selector(saveAccount), for: .touchUpInside)

        stack.addArrangedSubview(typeLabel)
        stack.addArrangedSubview(typePicker)
        stack.addArrangedSubview(subtypeLabel)
        stack.addArrangedSubview(subtypePicker)
        stack.addArrangedSubview(balanceField)
        stack.addArrangedSubview(overdraftField)
        stack.addArrangedSubview(statusLabel)
        stack.addArrangedSubview(isActiveSwitch)
        stack.addArrangedSubview(saveButton)

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    @objc private func saveAccount() {
        guard let user = user else {
            showAlert("Пользователь не найден")
            return
        }
        guard let rawBalanceText = balanceField.text, !rawBalanceText.isEmpty else {
            showAlert("Введите баланс")
            return
        }
        let balanceText = rawBalanceText.replacingOccurrences(of: ".", with: ",")

        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal

        guard let number = formatter.number(from: balanceText) else {
            showAlert("Введите корректный баланс")
            return
        }

        let balance = number.doubleValue

        var overdraftValue: Double? = nil
        if let rawOverdraftText = overdraftField.text, !rawOverdraftText.isEmpty {
            let overdraftText = rawOverdraftText.replacingOccurrences(of: ".", with: ",")
            if let overdraftNumber = formatter.number(from: overdraftText) {
                overdraftValue = overdraftNumber.doubleValue
            } else {
                showAlert("Введите корректный овердрафт")
                return
            }
        }

        let account = Account(
            id: UUID(),
            type: selectedAccountType,
            cardSubtype: selectedAccountType == .card ? selectedCardSubtype : nil,
            balance: balance,
            isActive: isActiveSwitch.isOn,
            isClosed: false,
            overdraftLimit: overdraftValue
        )

        DatabaseManager.shared.insertAccount(account: account, forUserLogin: user.login)
        navigationController?.popViewController(animated: true)
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}

extension AddAccountViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == typePicker {
            return accountTypes.count
        } else {
            return cardSubtypes.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == typePicker {
            return accountTypes[row].rawValue
        } else {
            return cardSubtypes[row].rawValue
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == typePicker {
            selectedAccountType = accountTypes[row]

            subtypePicker.isHidden = selectedAccountType != .card

            selectedCardSubtype = nil
            overdraftField.isHidden = true

        } else if pickerView == subtypePicker {
            selectedCardSubtype = cardSubtypes[row]

            overdraftField.isHidden = selectedCardSubtype != .salary
        }
    }
    @objc private func addAccount() {
        let addVC = AddAccountViewController()
        if let currentUser = UserData.loadCurrentUser() {
            addVC.user = currentUser
            navigationController?.pushViewController(addVC, animated: true)
        } else {
            print("Пользователь не найден — нельзя добавить счёт")
            let alert = UIAlertController(title: "Ошибка", message: "Не удалось определить текущего пользователя", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
        }
    }
}
