//
//  SocialMediaView.swift
//  SpeceApp
//
//  Created by Ja on 22/04/2025.
//

import SwiftUI

struct SocialMediaView: View {
    var body: some View {
        HStack (spacing: 5) {
            Button(action: {
                tappedButton()
            }) {
                Image(.Social.youtube)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.App.Button.normal)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button(action: {
                tappedButton()
            }) {
                Image(.Social.wiki)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.App.Button.normal)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
        }
        
    }
    func tappedButton() {
        
    }
}

#Preview {
    SocialMediaView()
}
