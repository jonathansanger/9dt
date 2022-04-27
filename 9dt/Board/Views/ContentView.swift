//
//  ContentView.swift
//  9dt
//
//  Created by Jonathan Sanger on 4/26/22.
//

import SwiftUI

struct ContentView: View {
	var viewModel = BoardViewModel()
	@ObservedObject var alertController = AlertController.shared
	
	var body: some View {
		VStack {
			BoardView(viewModel: viewModel)
		}
		.alert(isPresented: $alertController.showAlert) { () -> Alert in
			if let secondaryButton = alertController.secondaryButton {
				return Alert(title: Text(alertController.title), message: Text(alertController.message), primaryButton: alertController.primaryButton, secondaryButton: secondaryButton)
			}
			return Alert(title: Text(alertController.title), message: Text(alertController.message), dismissButton: alertController.primaryButton)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
