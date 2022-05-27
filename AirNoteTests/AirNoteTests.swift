//
//  AirNoteTests.swift
//  AirNoteTests
//
//  Created by Eric chung on 2022/5/20.
//

import XCTest

@testable import AirNote

class AirNoteTests: XCTestCase {
    
    var sut: ProfileViewController!
    
    override func setUpWithError() throws {
        sut = ProfileViewController()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFilterUsers() {
      // given
        let mySelf = User(followers: ["0"], followings: ["0"], joinedGroups: [], savedNotes: [], userAvatar: "", userGroups: [], userName: "", userNotes: [], uid: "1", blockUsers: [])
        let followerUids = mySelf.followers
        let otherUser = User(followers: ["1"], followings: ["1"], joinedGroups: [], savedNotes: [], userAvatar: "", userGroups: [], userName: "", userNotes: [], uid: "0", blockUsers: [])
        let allUsers = [mySelf, otherUser]

      // when
        sut.filterFollwers(followerUids, allUsers)

      // then
        XCTAssertEqual(sut.followers, [otherUser])
    }

}
