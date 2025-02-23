//
//  ARViewContainer.swift
//  Signify
//
//  Created by 김윤홍 on 2/22/25.
//

import SwiftUI
import Foundation
import ARKit

struct ARViewContainer: UIViewControllerRepresentable {

    @Binding var alphabet: String

    func makeUIViewController(context: Context) -> some UIViewController {
        let arViewController = ARViewController()
        arViewController.alphabetText = alphabet
        return arViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        let viewController = uiViewController as? ARViewController
        viewController?.alphabetText = alphabet
    }
}
