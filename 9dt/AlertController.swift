//
//  AlertController.swift
//  9dt
//
//  Created by Jonathan Sanger on 4/26/22.
//

import SwiftUI

class AlertController: ObservableObject {
	static var shared = AlertController()
	
	@Published var showAlert: Bool
	var title: String
	var message: String
	var primaryButton: Alert.Button
	var secondaryButton: Alert.Button?
	
	init() {
		self.showAlert = false
		self.title = ""
		self.message = ""
		self.primaryButton = .default(Text("Dismiss"))
		self.secondaryButton = nil
	}
	
	func reset() {
		self.showAlert = false
		self.title = ""
		self.message = ""
		self.primaryButton = .default(Text("Dismiss"))
		self.secondaryButton = nil
	}
}
