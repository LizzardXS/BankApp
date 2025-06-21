//
//  Lab9UITests.swift
//  Lab9UITests
//
//  Created by Елизавета Сенюк on 19.06.25.
//

import XCTest

final class Lab9UITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-UITests") 
        app.launch()
    }

    func testMainMenuButtonsExist() {
        let accountsButton = app.buttons["accountsButton"]
        let converterButton = app.buttons["converterButton"]
        let mapButton = app.buttons["mapButton"]

        XCTAssertTrue(accountsButton.waitForExistence(timeout: 5), "accountsButton не найдена")
        XCTAssertTrue(converterButton.waitForExistence(timeout: 5), "converterButton не найдена")
        XCTAssertTrue(mapButton.waitForExistence(timeout: 5), "mapButton не найдена")
    }

    func testOpenAccountsScreen() {
        let accountsButton = app.buttons["accountsButton"]
        XCTAssertTrue(accountsButton.exists, "Кнопка 'Просмотр счетов' не найдена")
        
        accountsButton.tap()
        
        let navBar = app.navigationBars["Ваши счета"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5), "Экран счетов не открылся")
    }

    func testOpenCurrencyConverter() {
        let converterButton = app.buttons["converterButton"]
        XCTAssertTrue(converterButton.exists, "Кнопка 'Конвертер валют' не найдена")
        
        converterButton.tap()
        
        let title = app.navigationBars["Конвертер валют"]
        XCTAssertTrue(title.exists, "Экран конвертера не открылся")
    }

    func testOpenMapScreen() {
        let mapButton = app.buttons["mapButton"]
        XCTAssertTrue(mapButton.exists, "Кнопка 'Отделения банка' не найдена")

        mapButton.tap()
        
    }
}
