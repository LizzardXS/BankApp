//
//  CurrencyViewController.swift
//  Lab 8 t1
//
//  Created by Елизавета Сенюк on 19.06.25.
//

import UIKit

class CurrencyConverterViewController: UIViewController, UITextFieldDelegate {

    let currencies = ["BYR", "RUB", "USD", "PLN", "EUR", "GBP", "JPY"]
    
    let exchangeRates: [String: Double] = [
        "BYR": 0.429,
        "RUB": 0.013,
        "USD": 1.0,
        "PLN": 0.23,
        "EUR": 1.08,
        "GBP": 1.25,
        "JPY": 0.0071
    ]
    
    var currencyFields: [String: UITextField] = [:]
    
    var isUpdating = false
    
    private let ratesLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Конвертер валют"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupRatesLabel()
        updateRatesLabel()
    }
    
    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        for currency in currencies {
            let label = UILabel()
            label.text = currency
            label.font = UIFont.boldSystemFont(ofSize: 16)
            
            let textField = UITextField()
            textField.placeholder = "Введите сумму в \(currency)"
            textField.borderStyle = .roundedRect
            textField.keyboardType = .decimalPad
            textField.delegate = self
            textField.tag = currencies.firstIndex(of: currency) ?? 0
            
            currencyFields[currency] = textField
            
            stack.addArrangedSubview(label)
            stack.addArrangedSubview(textField)
        }
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupRatesLabel() {
        ratesLabel.numberOfLines = 0
        ratesLabel.font = UIFont.systemFont(ofSize: 14)
        ratesLabel.textColor = .secondaryLabel
        ratesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(ratesLabel)
        
        NSLayoutConstraint.activate([
            ratesLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -180),
            ratesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ratesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    private func updateRatesLabel() {
        guard let byrToUSD = exchangeRates["BYR"] else { return }
        var text = "Курсы валют к BYR:\n"
        
        for currency in currencies {
            if currency == "BYR" { continue } 
            
            if let rateToUSD = exchangeRates[currency] {
                let rateToBYR = rateToUSD / byrToUSD
                text += "1 BYR = \(String(format: "%.4f", rateToBYR)) \(currency)\n"
            }
        }
        
        ratesLabel.text = text
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.convertValues(changedField: textField)
        }
        return true
    }
    
    private func convertValues(changedField: UITextField) {
        if isUpdating { return }
        isUpdating = true
        
        guard let changedCurrency = currencies[safe: changedField.tag],
              let text = changedField.text,
              let inputValue = Double(text.replacingOccurrences(of: ",", with: ".")) else {
            clearOtherFields(except: changedField)
            isUpdating = false
            return
        }
        
        let rateToUSD = exchangeRates[changedCurrency] ?? 1.0
        let valueInUSD = inputValue * rateToUSD
        
        for (currency, field) in currencyFields {
            if field == changedField { continue }
            if let rate = exchangeRates[currency] {
                let convertedValue = valueInUSD / rate
                field.text = String(format: "%.4f", convertedValue)
            }
        }
        
        isUpdating = false
    }
    
    private func clearOtherFields(except field: UITextField) {
        for (_, f) in currencyFields {
            if f != field {
                f.text = ""
            }
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
