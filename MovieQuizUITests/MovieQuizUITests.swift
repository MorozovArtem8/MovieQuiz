//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Artem Morozov on 12.04.2024.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
        
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
        
    }
    func testYesButton() {
        sleep(1)
        let indexLabel = app.staticTexts["Index"]
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(2)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(1)
        let indexLabel = app.staticTexts["Index"]
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(2)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testAlertPresenter() {
        sleep(1)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        sleep(1)
        let alert = app.alerts["Alert"]
        
        let alertTitleText = alert.label
        let alertButtonText = alert.buttons.firstMatch.label
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alertTitleText, "Этот раунд окончен!")
        XCTAssertEqual(alertButtonText, "Сыграть еще раз")
    }
    
    func testAlertDismiss() {
        sleep(1)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        sleep(1)
        let alert = app.alerts["Alert"]
        alert.buttons.firstMatch.tap()
        
        sleep(1)
        XCTAssertFalse(alert.exists)
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")
    }
    
    
    func testExample() throws {
        
        let app = XCUIApplication()
        app.launch()
        
    }
    
}
