//
//  BucketList.swift
//  WeSplit
//
//  Created by sailesh sirari on 16/10/24.
//

import Foundation
import SwiftUI
import MapKit
import LocalAuthentication

struct Location: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var description: String
    var latitude: Double
    var longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    static func ==(lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
    static let example = Location(id: UUID(), name: "Buckingham Palace", description: "Lit by over 40,000 lightbulbs.", latitude: 51.501, longitude: -0.141)
    
}
struct BucketList : View{
    @State private var viewModel = ViewModel()
    @State private var isUnlocked = false
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )
    
    
    
    var body : some View {
        if viewModel.isUnlocked {
            MapReader { proxy in
                Map(initialPosition: startPosition){
                    ForEach(viewModel.locations) { location in
                        Annotation(location.name, coordinate: location.coordinate) {
                            Image(systemName: "star.circle")
                                .resizable()
                                .foregroundStyle(.red)
                                .frame(width: 44, height: 44)
                                .background(.white)
                                .clipShape(.circle)
                                .onLongPressGesture {
                                    viewModel.selectedPlace = location
                                }
                        }
                    }
                }.sheet(item: $viewModel.selectedPlace) { place in
                    MarkerEditView(location: place) {
                        viewModel.update(location: $0)
                    }
                }
                .onTapGesture { position in
                    if let coordinate = proxy.convert(position, from: .local) {
                        viewModel.addLocation(at: coordinate)
                    }
                }
            }
        }else{
            
            Button("Unlock Places", action: viewModel.authenticate)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.capsule)
               
        }
        
    }
  
    
}

//#Preview {
//  var viewModel = BucketList.ViewModel()
//BucketList()
//}
