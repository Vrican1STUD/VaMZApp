//
//  UITabBarExtensions.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import UIKit

extension UITabBar {

    func setTabBarAppearance() {
        let appearance = UITabBarAppearance()

        let stackedAppearance = UITabBarItemAppearance(style: .stacked)

//        let fontAttributes = Font.tabBarItem.style.attributed

        let selectedTintColor = UIColor(resource: .Text.primary)//Color.Text.primary.color
        let unselectedIconColor = UIColor(resource: .App.Bar.normal)//Color.App.Bar.normal.color
        let unselectedTintColor = UIColor(resource: .Text.info)//Color.Text.info.color
        let backgroundColor = UIColor(resource: .App.background)

        appearance.backgroundEffect = UIBlurEffect(style: .dark)

        stackedAppearance.selected.iconColor = selectedTintColor
//        stackedAppearance.selected.titleTextAttributes = fontAttributes
        stackedAppearance.selected.titleTextAttributes = [.foregroundColor: selectedTintColor]

        stackedAppearance.normal.iconColor = unselectedIconColor
//        stackedAppearance.normal.titleTextAttributes = fontAttributes
        stackedAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedTintColor]
        
        appearance.stackedLayoutAppearance = stackedAppearance
        appearance.compactInlineLayoutAppearance = stackedAppearance
        appearance.inlineLayoutAppearance = stackedAppearance
        
        standardAppearance = appearance
        
        
        let scrollEdgeAppearance = UITabBarAppearance(barAppearance: appearance)
        scrollEdgeAppearance.backgroundColor = backgroundColor
        
        self.scrollEdgeAppearance = scrollEdgeAppearance
    }
    
}
