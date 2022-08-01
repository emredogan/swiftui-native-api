//
//  LottieView.swift
//  SwiftUI_NativeAPI
//
//  Created by Emre Dogan on 01/08/2022.
//

import Foundation
import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {

    var name: String!

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()

        let animationView = AnimationView()
        animationView.animation = Animation.named(name)
        animationView.contentMode = .scaleAspectFit

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
    }
}
