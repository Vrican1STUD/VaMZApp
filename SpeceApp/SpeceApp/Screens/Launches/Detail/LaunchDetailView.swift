//
//  LaunchDetailView.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import SwiftUI
import Kingfisher

struct LaunchDetailView: View {
    
    let id: String
    
    var body: some View {
        Text("LaunchDetail id:\n\(id)")
            .navigationTitle("Detail")
    }
}

#Preview {
    LaunchDetailView(id: "aaa")
}
