//
//  Account.swift
//  Lab 8 t1
//
//  Created by Елизавета Сенюк on 19.06.25.
//

import Foundation

enum AccountType: String {
    case current = "Текущий"
    case savings = "Сберегательный"
    case credit = "Кредитный"
    case card = "Карт-счет"
}

enum CardSubtype: String {
    case salary = "Зарплатный"
    case savings = "Сберегательный"
    case credit = "Кредитный"
}

struct Account {
    let id: UUID
    let type: AccountType
    let cardSubtype: CardSubtype?
    let balance: Double
    let isActive: Bool
    let isClosed: Bool
    let overdraftLimit: Double? 

    var description: String {
        var base = "\(type.rawValue)"
        if let subtype = cardSubtype {
            base += " (\(subtype.rawValue))"
        }
        return base
    }
}
