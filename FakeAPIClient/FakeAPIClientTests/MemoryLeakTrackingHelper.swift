//
//  MemoryLeakTrackingHelper.swift
//  FakeShopTests
//
//  Created by Mateusz Danioł on 09/04/2024.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
          addTeardownBlock { [weak instance] in
              XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line) // assert that instance of the sut is deallocated after tests
          }
      }
}
