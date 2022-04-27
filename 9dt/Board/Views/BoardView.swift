//
//  BoardView.swift
//  9dt
//
//  Created by Jonathan Sanger on 4/26/22.
//

import SwiftUI

struct BoardView: View {
	@ObservedObject var viewModel: BoardViewModel
	
	var isBoardEnabled: Bool {
		return viewModel.canPlay && viewModel.activePlayer == .player1
	}
	
	let kCircleSize: CGFloat = 50
	
	var body: some View {
		VStack {
			Text("9dt").font(.largeTitle)
				.padding(.bottom, 20)
			
			//Welcome screen
			if viewModel.showWelcome {
				VStack {
					Text("Wecome to 9dt!").font(.title2)
						.padding(.bottom, 10)
					Text("Your goal is to get four of your chips in a line. Tapping a column adds your chip to it. You'll be playing against the computer.").fixedSize(horizontal: false, vertical: true)
						.padding(.bottom, 10)
					
					Text("Who should go first?")
					HStack {
						Button(action: {
							self.viewModel.activePlayer = .player1
							self.viewModel.showWelcome = false
						}) {
							Text("I'll go first")
								.padding()
								.background(Color.gray.cornerRadius(10).opacity(0.3))
						}
						
						Button(action: {
							self.viewModel.activePlayer = .computer
							self.viewModel.getComputerPlay()
							self.viewModel.showWelcome = false
						}) {
							Text("The computer")
								.padding()
								.background(Color.gray.cornerRadius(10).opacity(0.3))
						}
					}
					ChipBoard(boardContents: viewModel.mockFullBoardDiagonalWin(), kCircleSize: 50, onColumnTapped: {_ in})
						.disabled(true)
						.opacity(0.6)
						.padding(.vertical, 20)
				}
				.padding(.horizontal, 20)
			}
			
			//Main playable board
			else {
				VStack {
					HStack {
						Text("Active player: \(viewModel.activePlayer == .player1 ? "player1" : "computer")")
						Circle().fill(viewModel.activePlayer == .player1 ? .blue : .red).frame(width: 30, height: 30)
					}.padding(.horizontal, 20)
					HStack {
						ForEach(Array(Array(0..<viewModel.boardWidth).enumerated()), id: \.offset) { idx, element in
							Button(action: {
								self.viewModel.makeMove(player: viewModel.activePlayer, column: idx)
							}) {
								Circle().stroke(lineWidth: 3).fill(.blue).frame(width: kCircleSize, height: kCircleSize)
							}
							.disabled(!isBoardEnabled)
						}
					}
					
					ChipBoard(boardContents: viewModel.boardContents,
							  kCircleSize: kCircleSize,
							  onColumnTapped: { columnIdx in
						self.viewModel.makeMove(player: viewModel.activePlayer, column: columnIdx)
					})
					.disabled(!isBoardEnabled)
					
					Button(action: {
						viewModel.reset()
					}) {
						Text("Reset the board")
					}.opacity(viewModel.canPlay ? 0 : 1)
				}
			}
			Spacer()
		}
	}
}



struct BoardView_Previews: PreviewProvider {
	static var previews: some View {
		BoardView(viewModel: BoardViewModel())
	}
}
