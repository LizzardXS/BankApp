//
//  DataBaseManager.swift
//  Lab 8 t1
//
//  Created by Елизавета Сенюк on 19.06.25.
//

import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection!
    
    private let accountsTable = Table("accounts")
    
    private let id = Expression<UUID>("id")
    private let type = Expression<String>("type")
    private let cardSubtype = Expression<String?>("card_subtype")
    private let balance = Expression<Double>("balance")
    private let isActive = Expression<Bool>("is_active")
    private let isClosed = Expression<Bool>("is_closed")
    private let overdraftLimit = Expression<Double?>("overdraft_limit")
    private let userLogin = Expression<String>("user_login")
    
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        do {
            db = try Connection("\(path)/bank.db")
            createTable()
        } catch {
            print("Ошибка подключения к базе данных: \(error)")
        }
    }
    
    private func createTable() {
        do {
            try db.run(accountsTable.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(type)
                t.column(cardSubtype)
                t.column(balance)
                t.column(isActive)
                t.column(isClosed)
                t.column(overdraftLimit)
                t.column(userLogin)
                
            })
        } catch {
            print("Ошибка при создании таблицы: \(error)")
        }
    }
    
    func insertAccount(account: Account, forUserLogin login: String) {
        do {
            let insert = accountsTable.insert(
                id <- account.id,
                type <- account.type.rawValue,
                cardSubtype <- account.cardSubtype?.rawValue,
                balance <- account.balance,
                isActive <- account.isActive,
                isClosed <- account.isClosed,
                overdraftLimit <- account.overdraftLimit,
                userLogin <- login
            )
            try db.run(insert)
        } catch {
            print("Ошибка при добавлении записи в таблицу: \(error)")
        }
    }
    
    func fetchAccounts(forUserLogin login: String) -> [Account] {
        var accounts: [Account] = []
        do {
            let query = accountsTable
                .filter(userLogin == login && isClosed == false)
            
            for row in try db.prepare(query) {
                let accountType = AccountType(rawValue: row[type])!
                let cardType: CardSubtype? = row[cardSubtype].flatMap { CardSubtype(rawValue: $0) }
                
                let account = Account(
                    id: row[id],
                    type: accountType,
                    cardSubtype: cardType,
                    balance: row[balance],
                    isActive: row[isActive],
                    isClosed: row[isClosed],
                    overdraftLimit: row[overdraftLimit]
                )
                accounts.append(account)
            }
        } catch {
            print("Ошибка при извлечении данных: \(error)")
        }
        return accounts
    }
}
