//
//  CluetoothUITests.swift
//  CluetoothUITests
//
//  Created by Edu Caubilla on 2/9/25.
//

import XCTest

final class MainViewUITests: XCTestCase {

    var app: XCUIApplication!
    var timeout: TimeInterval = 2

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testNavigationBarTitle() throws {
        XCTAssertTrue(app.navigationBars["Cluetooth"].exists, "Navigation title should be 'Cluetooth'")
    }

    func testScanButtonStartsScanning() throws {
        let scanButton = app.buttons["Scan Button"]
        XCTAssertTrue(scanButton.exists, "Scan button should exist")

        scanButton.tap()

        // Expect that scanning starts → ProgressView should appear
        let progressIndicator = app.activityIndicators.firstMatch
        XCTAssertTrue(progressIndicator.waitForExistence(timeout: 2), "Progress indicator should appear after scanning starts")
    }

    func testDeviceListAppearsAfterScan() throws {
        let scanButton = app.buttons["Scan Button"]
        scanButton.tap()

        // Simulate devices appearing (depends on your test doubles / mock manager)
        let deviceCell = app.cells.firstMatch
        XCTAssertTrue(deviceCell.waitForExistence(timeout: 3), "Device cell should appear after scanning")
    }

    func testResetListButtonAppearsWhenDevicesFound() throws {
        let scanButton = app.buttons["Scan Button"]
        scanButton.tap()

        // Wait for first device cell
        let deviceCell = app.cells.firstMatch
        XCTAssertTrue(deviceCell.waitForExistence(timeout: 3))

        let resetButton = app.buttons["Reset list"]
        XCTAssertTrue(resetButton.exists, "Reset list button should appear when devices are found")
    }

    func testExpandAndCollapseDeviceCell() throws {
        let scanButton = app.buttons["Scan Button"]
        scanButton.tap()

        let deviceCell = app.cells.firstMatch
        XCTAssertTrue(deviceCell.waitForExistence(timeout: 3))

        // Tap the chevron/button in the cell
        deviceCell.images.firstMatch.tap()

        let expandedText = app.staticTexts["Device is connectable"]
        XCTAssertTrue(expandedText.firstMatch.waitForExistence(timeout: 2), "Expanded services should appear")

        // Tap again to collapse
        deviceCell.images.firstMatch.tap()
        XCTAssertFalse(expandedText.firstMatch.exists, "Expanded services should disappear after collapsing")
    }

    func testDeviceDetailNavigation() throws {
        let scanButton = app.buttons["Scan Button"]
        scanButton.tap()

        let connectButton = app.buttons["Connect"].firstMatch
        connectButton.tap()

        sleep(8)

        let connectedButton = app.buttons["Connected"].firstMatch
        XCTAssertTrue(connectedButton.waitForExistence(timeout: 5))

        // Simulate tapping chevron for connected device
        let chevronButton = app.images.firstMatch
        chevronButton.tap()

        print(XCUIApplication().debugDescription)

        let detailView = app.otherElements["DeviceView"] // assign accessibilityIdentifier in DeviceView
        XCTAssertTrue(detailView.waitForExistence(timeout: 5), "Device detail view should appear when tapping chevron on a connected device")
    }

    func testConnectionTimeoutAlert() throws {
        // Simulate error by making your mock manager emit "Connection timed out."
        let alert = app.alerts["Connection Timed Out"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2), "Alert should appear if connection times out")
        XCTAssertTrue(alert.staticTexts["The device couldn't be connected. You may get closer or make sure it is turned on and try again."].exists)
        alert.buttons["Ok"].tap()
    }
}
