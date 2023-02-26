//
//  UIImage+ExtensionsTests.swift
//  Card TrackerTests
//
//  Created by Michael Rowe on 2/12/23.
//  Copyright © 2023 Michael Rowe. All rights reserved.
//

import XCTest
import UIKit

class UIImageExtensionsTests: XCTestCase {

    func testResizedWithPercentage() {
        let image = UIImage(named: "frontImage")!
        let resizedImage = image.resized(withPercentage: 0.5)
        XCTAssertEqual(resizedImage?.size.width, image.size.width * 0.5)
        XCTAssertEqual(resizedImage?.size.height, image.size.height * 0.5)
    }

    func testResizedToWidth() {
        let image = UIImage(named: "frontImage")!
        let resizedImage = image.resized(toWidth: 100)
        XCTAssertEqual(resizedImage?.size.width, 100)
    }

    func testFixOrientation() {
        let image = UIImage(named: "frontImage")!
        let fixedImage = image.fixOrientation()
        XCTAssertEqual(fixedImage.imageOrientation, UIImage.Orientation.up)
    }

    func testResizeByByte() {
        let image = UIImage(named: "frontImage")!
        let maxByte = 1000
        let expectation = self.expectation(description: "Data should be returned.")
        image.resizeByByte(maxByte: maxByte) { (data) in
            XCTAssertGreaterThanOrEqual(data.count, maxByte)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testJPEGQuality() {
        let image = UIImage(named: "frontImage")!
        let jpegQuality = UIImage.JPEGQuality.high
        let jpegData = image.jpeg(jpegQuality)
        XCTAssertNotNil(jpegData)
    }
}
