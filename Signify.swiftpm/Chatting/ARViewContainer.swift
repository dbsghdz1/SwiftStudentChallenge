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
    var isLearningMode: Bool

    func makeUIViewController(context: Context) -> some UIViewController {
        let arViewController = ARViewController(isLearningMode: isLearningMode)
        arViewController.alphabetText = alphabet
        return arViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        let viewController = uiViewController as? ARViewController
        viewController?.alphabetText = alphabet
    }
}
