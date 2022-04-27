//
//  _dtTests.swift
//  9dtTests
//
//  Created by Jonathan Sanger on 4/26/22.
//

import XCTest
@testable import _dt

class _dtTests: XCTestCase {
	var sut: BoardViewModel!
	
	override func setUp() {
		super.setUp()
		sut = BoardViewModel()
	}

	func testDiagonalWins() throws {
		sut.boardContents = sut.mockFullBoardDiagonalWin()
		let winner = sut.diagonalHasAWinner()
		if winner == .player1 {
			XCTAssertTrue(true)
		}
		else {
			XCTFail()
		}
	}
	
	func testRowWins() throws {
		sut.boardContents = sut.mockFullBoardRowWin()
		let winner = sut.rowHasAWinner()
		if winner == .player1 {
			XCTAssertTrue(true)
		}
		else {
			XCTFail()
		}
	}
	
	func testPlayer1Turn() {
		sut.activePlayer = .computer
		sut.makeMove(player: .computer, column: 2)
		XCTAssert(sut.activePlayer == .player1)
	}
}
