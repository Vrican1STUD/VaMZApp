//
//  UINavigationBarExtensions.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import UIKit

extension UINavigationBar {

    static func setAppearance() {
        let appearance = self.appearance()
        appearance.prefersLargeTitles = true
        appearance.isTranslucent = true

        let standartAppearance = UINavigationBarAppearance()

        let fontColor = UIColor(resource: .Text.primary)

//        standartAppearance.largeTitleTextAttributes = Font.largeTitle.style.attributed
        standartAppearance.largeTitleTextAttributes = [.foregroundColor: fontColor]

//        standartAppearance.titleTextAttributes = Font.body.style.attributed
        standartAppearance.titleTextAttributes = [.foregroundColor: fontColor]

        standartAppearance.backgroundEffect = UIBlurEffect(style: .dark)

        standartAppearance.shadowColor = .clear
        standartAppearance.shadowImage = UIImage()

        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        standartAppearance.backButtonAppearance = backButtonAppearance

        appearance.standardAppearance = standartAppearance

        let scrollEdgeAppearance = UINavigationBarAppearance(barAppearance: standartAppearance)
        scrollEdgeAppearance.backgroundColor = UIColor(resource: .App.background)

        appearance.scrollEdgeAppearance = scrollEdgeAppearance
        appearance.compactAppearance = scrollEdgeAppearance
    }

    func setTransparentBackground() {
            prefersLargeTitles = false
            let appearance = UINavigationBarAppearance()
        
                appearance.backgroundImage = UIImage()
                appearance.shadowImage = UIImage()
                appearance.shadowColor = .clear
                appearance.backgroundEffect = nil
            

            let backButtonAppearance = UIBarButtonItemAppearance()
            backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            appearance.backButtonAppearance = backButtonAppearance
            standardAppearance = appearance
        tintColor = UIColor(resource: .Text.primary)
        }

    func undoTransparentBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundImage = nil
        appearance.shadowImage = UIImage()
        appearance.backgroundEffect = UIBlurEffect(style: .dark)
        

        let fontColor = UIColor(resource: .Text.primary)

//        appearance.largeTitleTextAttributes = Font.largeTitle.style.attributed
        appearance.largeTitleTextAttributes = [.foregroundColor: fontColor]

//        appearance.titleTextAttributes = Font.body.style.attributed
        appearance.titleTextAttributes = [.foregroundColor: fontColor]

        standardAppearance = appearance
    }

}
