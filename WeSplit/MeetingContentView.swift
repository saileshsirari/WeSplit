//
//  MeetingContentView.swift
//  WeSplit
//
//  Created by sailesh sirari on 21/10/24.
//

import SwiftUI

struct MeetingContentView: View {
    var body: some View {
        TabView {
            ProspectsView(filter:FilterType.none)
                .tabItem {
                    Label("Everyone", systemImage: "person.3")
                }
            ProspectsView(filter:FilterType.contacted)
                .tabItem {
                    Label("Contacted", systemImage: "checkmark.circle")
                }
            ProspectsView(filter:FilterType.uncontacted)
                .tabItem {
                    Label("Uncontacted", systemImage: "questionmark.diamond")
                }
            MeView()
                .tabItem {
                    Label("Me", systemImage: "person.crop.square")
                }
        }
    }
}

#Preview {
    MeetingContentView()
}
