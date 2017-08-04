//
//  VKFileBrowserDemoTests.swift
//  VKFileBrowserDemoTests
//
//  Created by Vk on 2016/9/30.
//  Copyright © 2016年 vk. All rights reserved.
//

import XCTest
//@testable import VKFileBrowserDemo

class VKFileBrowserDemoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let content = "-(void) clickView:(id) sender{"
        let results = content.keywordRanges(of: "id")
        
        
        assert(results.count == 1)
        
        let range = results[0]
        let substr = content.substring(with: range)
        
        assert(substr == "id")
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        
        
        
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
