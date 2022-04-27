//
//  BoardViewModel.swift
//  9dt
//
//  Created by Jonathan Sanger on 4/26/22.
//

import SwiftUI

class BoardViewModel: ObservableObject {
	@Published var boardContents: [[Player]]
	@Published var canPlay: Bool
	@Published var activePlayer: Player
	@Published var showWelcome: Bool
	var moves: [Int]
	let boardWidth: Int
	let boardHeight: Int
	
	init(boardWidth: Int = 4, boardHeight: Int = 4, activePlayer: Player = .player1) {
		self.boardWidth = boardWidth
		self.boardHeight = boardHeight
		self.boardContents = [[]]
		self.canPlay = true
		self.activePlayer = activePlayer
		self.showWelcome = true
		self.moves = []
		self.initializeBoard()
	}
	
	func reset() {
		self.initializeBoard()
		self.canPlay = true
		self.activePlayer = .player1
		self.showWelcome = true
		self.moves = []
	}
	
	private func initializeBoard() {
		var board: [[Player]] = []
		for _ in 0..<boardHeight {
			let row = Array(repeating: Player.empty, count: boardWidth)
			board.append(row)
		}
		self.boardContents = board
	}
	
	func handleError(_ errorMessage: String? = nil) {
		let message = errorMessage ?? "Your opponent got a little confused. We need to reset the board."
		let alert = AlertController.shared
		alert.title = "Something's not right"
		alert.message = message
		alert.primaryButton = .default(Text("Reset")) {
			self.reset()
			alert.reset()
		}
		
		DispatchQueue.main.async {
			alert.showAlert = true
		}
	}
	
	func getComputerPlay() {
		let baseUrl = URL(string: "https://w0ayb2ph1k.execute-api.us-west-2.amazonaws.com/production")!
		let stringMoves: String = "[\(moves.compactMap({ String($0)}).joined(separator: ","))]"
		let queryItem = URLQueryItem(name: "moves", value: stringMoves)
		var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
		components?.queryItems = [queryItem]
		guard let url = components?.url else {
			return
		}
		let request = URLRequest(url: url)
	
		let session = URLSession.shared.dataTask(with: request, completionHandler: { data, urlResponse, error in
			guard let urlResponse = urlResponse as? HTTPURLResponse else {
				return
			}
			guard urlResponse.statusCode == 200 else {
				self.handleError()
				return
			}
			guard let data = data, let json = try? JSONSerialization.jsonObject(with: data) else {
				self.handleError()
				return
			}
			guard let movesArray = json as? [Int], let computerMove = movesArray.last else {
				self.handleError()
				return
			}
			DispatchQueue.main.async {
				self.makeMove(player: .computer, column: computerMove)
			}
		})
		session.resume()
	}
	
	func makeMove(player: Player = .player1, column: Int) {
		var didPlay = false
		var i = boardContents.count - 1
		while i >= 0 {
			if boardContents[i][column] == .empty {
				boardContents[i][column] = player
				didPlay = true
				self.moves.append(column)
				self.checkForWinner()
				break
			}
			i -= 1
		}
		if !didPlay {
			let alert = AlertController.shared
			alert.title = "Colum full"
			alert.message = "Try a column with empty space."
			alert.primaryButton = .cancel(Text("Dismiss")) {
				alert.reset()
			}
			DispatchQueue.main.async {
				alert.showAlert = true
			}
		}
	}
	
	func getNextPlayer() {
		if activePlayer == .player1 {
			self.activePlayer = .computer
			self.getComputerPlay()
		}
		else {
			activePlayer = .player1
		}
	}
	
	func checkForWinner() {
		if let winner = rowHasAWinner() {
			endGame(winner)
			return
		}
		if let winner = columnHasAWinner() {
			endGame(winner)
			return
		}
		if let winner = diagonalHasAWinner() {
			endGame(winner)
			return
		}
		guard !checkIfDraw() else {
			self.endGame(nil)
			return
		}
		
		self.getNextPlayer()
	}
	
	func checkIfDraw() -> Bool {
		guard let topRow = boardContents.first else {
			return false
		}
		return topRow.allSatisfy({$0 != .empty})
	}
	
	func rowHasAWinner() -> Player? {
		for row in boardContents {
			if let winner = checkIfTeamWins(row) {
				return winner
			}
		}
		return nil
	}

	func columnHasAWinner() -> Player? {
		for i in 0..<boardContents.count {
			let column = boardContents.compactMap( {$0[i]})
			if let winner = checkIfTeamWins(column) {
				return winner
			}
		}
		return nil
	}
	
	func diagonalHasAWinner() -> Player? {
		var topLeft: [Player] = []
		var bottomRight: [Player] = []
		for i in 0..<boardContents.count {
			topLeft.append(boardContents[i][i])
			bottomRight.append(boardContents[boardContents.count - 1 - i][i])
		}
		
		if let winner = checkIfTeamWins(topLeft) {
			return winner
		}
		if let winner = checkIfTeamWins(bottomRight) {
			return winner
		}
		return nil
	}
	
	func endGame(_ winner: Player?) {
		//Disable board
		self.canPlay = false
		let alert = AlertController.shared
		
		if let winner = winner {
			if winner == .player1 {
				alert.title = "Congrats!"
				alert.message = "You won! Can you do that again?"
				
			}
			else {
				alert.title = "Womp womp"
				alert.message = "You lost. Try to do better next time."
			}
		}
		else {
			alert.title = "Shucks"
			alert.message = "That's a draw. Want to try again?"
		}
		
		alert.primaryButton = .default(Text("Play again")) {
			alert.reset()
			self.reset()
		}
		alert.secondaryButton = .cancel() {
			alert.reset()
		}
		DispatchQueue.main.async {
			alert.showAlert = true
		}
	}
	
	func checkIfTeamWins(_ array: [Player]) -> Player? {
		if array.allSatisfy({$0 == .player1}) {
			return .player1
		}
		if array.allSatisfy({$0 == .computer}) {
			return .computer
		}
		return nil
	}
	
	func mockFullBoardDiagonalWin() -> [[Player]] {
		let row1: [Player] = [.player1, .computer, .player1, .player1]
		let row2: [Player] = [.computer, .computer, .player1, .computer]
		let row3: [Player] = [.player1, .player1, .player1, .computer]
		let row4: [Player] = [.player1, .computer, .computer, .computer]
		let board = [row1, row2, row3, row4]
		return board
	}
	
	func mockFullBoardRowWin() -> [[Player]] {
		let row1: [Player] = [.player1, .player1, .player1, .player1]
		let row2: [Player] = [.computer, .computer, .player1, .computer]
		let row3: [Player] = [.player1, .computer, .player1, .computer]
		let row4: [Player] = [.player1, .computer, .computer, .computer]
		let board = [row1, row2, row3, row4]
		return board
	}
}
