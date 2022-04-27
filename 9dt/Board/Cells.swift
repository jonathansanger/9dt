//
//  Cells.swift
//  9dt
//
//  Created by Jonathan Sanger on 4/26/22.
//

import Foundation

enum CellContents: String {
	//Contents could actually be player or computer, but type erased?
	case /*unknown,*/ empty, red, blue
}

enum Player: Int {
	case player1
	case computer
}
