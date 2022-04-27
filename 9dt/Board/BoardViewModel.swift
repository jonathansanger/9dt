//
//  BoardViewModel.swift
//  9dt
//
//  Created by Jonathan Sanger on 4/26/22.
//

import SwiftUI

class BoardViewModel: ObservableObject {
	@Published var boardContents: [[CellContents]]
	@Published var canPlay: Bool
	@Published var activePlayer: Player
	var moves: [Int]
	init(_ boardWidth: Int = 4, boardHeight: Int = 4, activePlayer: Player = .player1) {
		self.boardContents = [[]]
		self.canPlay = true
		self.activePlayer = activePlayer
		self.moves = []
		self.initializeBoard(width: boardWidth, height: boardWidth)
	}
	
	func reset() {
		self.initializeBoard(width: 4, height: 4)
		self.canPlay = true
		self.activePlayer = .player1
		self.moves = []
	}
	
	private func initializeBoard(width: Int, height: Int) {
		var board: [[CellContents]] = []
		for _ in 0..<height {
			let row = Array(repeating: CellContents.empty, count: 4)
			board.append(row)
		}
		self.boardContents = board
	}
	
	
	func getComputerPlay() {
//		let moves = [10, 2, 4]
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
				//TODO: throw error!
				print("some status code error")
				return
			}
			guard let data = data, let json = try? JSONSerialization.jsonObject(with: data) else {
				print("NOT JSON?!")
				return
			}
			guard let movesArray = json as? [Int], let computerMove = movesArray.last else {
				print("some other error")
				//Error
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
				boardContents[i][column] = player == .player1 ? .blue : .red
				didPlay = true
				self.moves.append(column)
				self.checkForWinner()
				break
			}
			i -= 1
		}
		if !didPlay {
			print("ERRORERERSSSS")
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
	
	func rowHasAWinner() -> CellContents? {
		for row in boardContents {
			if let winner = checkIfTeamWins(row) {
				return winner
			}
		}
		return nil
	}

	func columnHasAWinner() -> CellContents? {
		for i in 0..<boardContents.count {
			let column = boardContents.compactMap( {$0[i]})
			if let winner = checkIfTeamWins(column) {
				return winner
			}
		}
		return nil
	}
	
	func diagonalHasAWinner() -> CellContents? {
		var topLeft: [CellContents] = []
		var bottomRight: [CellContents] = []
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
	
	func endGame(_ winner: CellContents?) {
		//Disable board
		self.canPlay = false
		//TODO: handlo draw (nil), or winner, and give user option to reset
		let alert = AlertController.shared
		
		if let winner = winner {
			if winner == .blue {
				alert.title = "Congrats!"
				alert.message = "You won! Do you want to see if you can do that again?"
				
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
			self.reset()
		}
		alert.secondaryButton = .cancel()
		DispatchQueue.main.async {
			alert.showAlert = true
		}
		print("WINNER!: \(winner)")
	}
	
	func checkIfTeamWins(_ array: [CellContents]) -> CellContents? {
		if array.allSatisfy({$0 == .blue}) {
			return .blue
		}
		if array.allSatisfy({$0 == .red}) {
			return .red
		}
		return nil
	}
}
