//
//  MissionView.swift
//  WeSplit
//
//  Created by sailesh sirari on 07/10/24.
//

import Foundation
import SwiftUI
struct CrewMember {
    let role: String
    let astronaut: Astronaut
}
struct MissionView: View {
    let mission: Mission
    let crew: [CrewMember]
    @State private var showAsList = false
    init(mission: Mission, astronauts: [String: Astronaut]) {
        self.mission = mission

        self.crew = mission.crew.map { member in
            if let astronaut = astronauts[member.name] {
                return CrewMember(role: member.role, astronaut: astronaut)
            } else {
                fatalError("Missing \(member.name)")
            }
        }
    }
  
    var body: some View {
        ScrollView {
            VStack {
                Image(mission.image)
                    .resizable()
                    .scaledToFit()
                    .containerRelativeFrame(.horizontal) { width, axis in
                        width * 0.6
                    }
                    .padding(.top)
              

                VStack(alignment: .leading) {
                    Text("Mission Highlights")
                        .font(.title.bold())
                        .padding(.bottom, 5)
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(.lightBackground)
                        .padding(.vertical)

                    Text(mission.description)
                }
                .padding(.horizontal)
                Text("Crew")
                    .font(.title.bold())
                    .padding(.bottom, 5)
              
                    horizontalCrewView(crew: crew)
                
                
              
              
            }
            .padding(.bottom)
        }
        .navigationTitle(mission.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .background(.darkBackground)
    }
}
struct horizontalCrewView :View{
    let crew: [CrewMember]
    var body: some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(crew, id: \.role) { crewMember in
                    NavigationLink {
                        AstronautView(astronaut: crewMember.astronaut)
                    } label: {
                        HStack {
                            Image(crewMember.astronaut.id)
                                .resizable()
                                .frame(width: 154, height: 172)
                                .clipShape(.capsule)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(.white, lineWidth: 1)
                                ).padding()

                            VStack(alignment: .leading) {
                                Text(crewMember.astronaut.name)
                                    .foregroundStyle(.white)
                                    .font(.headline)
                                Text(crewMember.role)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

#Preview {
    let missions: [Mission] = Bundle.main.decode("missions.json")
    let astronauts: [String:Astronaut] = Bundle.main.decode("astronauts.json")

    return MissionView(mission: missions[0],astronauts: astronauts)
        .preferredColorScheme(.dark)
}
