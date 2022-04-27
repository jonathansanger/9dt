//
//  BoardView.swift
//  9dt
//
//  Created by Jonathan Sanger on 4/26/22.
//

import SwiftUI

struct BoardView: View {
	@ObservedObject var viewModel: BoardViewModel
	
	func cellColor(_ cellContents: CellContents) -> Color {
		switch cellContents {
		case .empty:
			return .yellow
		case .blue:
			return .blue
		case .red:
			return .red
		}
	}
	
	var areColumnsEnabled: Bool {
		return viewModel.canPlay && viewModel.activePlayer == .player1
	}
	
	let kCircleSize: CGFloat = 50
	var body: some View {
		VStack {
			Button(action: {
				viewModel.reset()
			}) {
				Text("Reset the board")
			}.opacity(viewModel.canPlay ? 0 : 1)
			HStack {
				Text("Active player: \(viewModel.activePlayer == .player1 ? "player1" : "computer")")
					 Circle().fill(viewModel.activePlayer == .player1 ? .blue : .red).frame(width: 30, height: 30)
				Spacer()
			}
			HStack {
				ForEach(Array(Array(0...3).enumerated()), id: \.offset) { idx, element in
					Button(action: {
						print(idx)
						self.viewModel.makeMove(player: viewModel.activePlayer, column: idx)
					}) {
						Circle().stroke(lineWidth: 3).fill(.blue).frame(width: kCircleSize, height: kCircleSize)
					}
					.disabled(!areColumnsEnabled)
				}
			}
			ForEach(Array(viewModel.boardContents.enumerated()), id: \.offset) { rowIdx, row in
				HStack {
					ForEach(Array(row.enumerated()), id: \.offset) { columnIdx, element in
						Circle().fill(cellColor(row[columnIdx])).frame(width: kCircleSize, height: kCircleSize).onTapGesture {
							print("tapped!: row: \(rowIdx), column: \(columnIdx)")
						}
					}
				}
			}
		}
	}
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(viewModel: BoardViewModel())
    }
}
