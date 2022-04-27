//
//  ChipBoard.swift
//  9dt
//
//  Created by Jonathan Sanger on 4/27/22.
//

import SwiftUI

struct ChipBoard: View {
	var boardContents: [[Player]]
	let kCircleSize: CGFloat
	var onColumnTapped: (Int) -> Void
	
	func cellColor(_ player: Player) -> Color {
		switch player {
		case .empty:
			return .yellow
		case .player1:
			return .blue
		case .computer:
			return .red
		}
	}
	
	var body: some View {
		VStack {
			ForEach(Array(boardContents.enumerated()), id: \.offset) { rowIdx, row in
				HStack {
					ForEach(Array(row.enumerated()), id: \.offset) { columnIdx, element in
						Circle().fill(cellColor(row[columnIdx])).frame(width: kCircleSize, height: kCircleSize).onTapGesture {
							onColumnTapped(columnIdx)
						}
					}
				}
			}
		}
		.padding()
		.background(Rectangle().stroke(Color.black.opacity(0.3), lineWidth: 3))
	}
}

struct ChipBoard_Previews: PreviewProvider {
	static var previews: some View {
		let viewModel = BoardViewModel()
		return ChipBoard(boardContents: viewModel.boardContents, kCircleSize: 50, onColumnTapped: { _ in })
	}
}
