//
//  MarkerEditView.swift
//  WeSplit
//
//  Created by sailesh sirari on 16/10/24.
//

import Foundation
import SwiftUI
import MapKit
enum LoadingState {
    case loading, loaded, failed
}
struct MarkerEditView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewmodel: ViewModel = ViewModel()
    
    @State var name: String = ""
    @State  var description: String = ""
    var location : Location
    var onSave: (Location) -> Void
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
    }
    
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place name", text: $name)
                    TextField("Description", text: $description)
                }
                
                Section("Nearby…") {
                    switch viewmodel.loadingState {
                    case .loaded:
                        ForEach(viewmodel.pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            + Text(": ") +
                            Text(page.description)
                            
                                .italic()
                        }
                    case .loading:
                        Text("Loading…")
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save") {
                    var newLocation = self.location
                    newLocation.name = name
                    newLocation.id = UUID()
                    newLocation.description = description
                    viewmodel.save(newLocation:newLocation, onSave: onSave)
                    dismiss()
                   
                }
            }.task {
                await viewmodel.fetchNearbyPlaces(loc: location)
            }
        }
    }
    
}
#Preview {
    MarkerEditView(location: .example) { _ in }
}

extension MarkerEditView {
    @Observable
    class ViewModel {
        var loadingState = LoadingState.loading
        var pages = [Page]()
        
        init(){
            
        }
        
        
        func fetchNearbyPlaces(loc : Location) async {
            let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(loc.latitude)%7C\(loc.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
            
            guard let url = URL(string: urlString) else {
                print("Bad URL: \(urlString)")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // we got some data back!
                let items = try JSONDecoder().decode(Result.self, from: data)
                
                // success – convert the array values to our pages array
                pages = items.query.pages.values.sorted()
                loadingState = .loaded
            } catch {
                // if we're still here it means the request failed somehow
                loadingState = .failed
            }
        }
        func save(newLocation : Location,  onSave: (Location) -> Void){
            onSave(newLocation)
        }
        
        
    }
}
