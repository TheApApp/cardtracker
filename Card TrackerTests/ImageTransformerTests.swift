//
//  ImageTransformerTests.swift
//  Card TrackerTests
//
//  Created by Michael Rowe on 2/12/23.
//  Copyright © 2023 Michael Rowe. All rights reserved.
//

import XCTest
@testable import Card_Tracker

class ImageTransformerTests: XCTestCase {

    var transformer: ImageTransformer!

    override func setUp() {
        super.setUp()
        transformer = ImageTransformer()
    }

    func testAllowsReverseTransformation() {
        XCTAssertTrue(ImageTransformer.allowsReverseTransformation())
    }

    func testTransformedValue() {
        let image = UIImage(named: "frontImage")!
        let transformedValue = transformer.transformedValue(image) as? Data
        XCTAssertNotNil(transformedValue)
    }

    func testReverseTransformedValue() {
        let image = UIImage(named: "frontImage")!
        let imageData = image.jpegData(compressionQuality: 1.0)
        let reverseTransformedValue = transformer.reverseTransformedValue(imageData) as? UIImage
        XCTAssertNotNil(reverseTransformedValue)
    }

}
