//
//  ContentView-ViewModel.swift
//  WeSplit
//
//  Created by sailesh sirari on 17/10/24.
//

import Foundation
import CoreLocation
import LocalAuthentication

extension BucketList {
    @Observable
    class ViewModel {
        private(set) var locations : [Location]
        var isUnlocked = false
        var biometricError = false

        var selectedPlace: Location?
        let savePath = URL.documentsDirectory.appending(path: "SavedPlaces")
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
           
        }
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
        func addLocation(at point: CLLocationCoordinate2D) {
            let newLocation = Location(id: UUID(), name: "New location", description: "", latitude: point.latitude, longitude: point.longitude)
            locations.append(newLocation)
            save()
        }
        func update(location: Location) {
            guard let selectedPlace else { return }

            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
            }
            save()
        }
        
        func authenticate() {
            let context = LAContext()
            var error: NSError?
         
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places."

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in

                    if success {
                        self.isUnlocked = true
                    } else {
                        // error
                        self.biometricError = true
                    }
                }
            } else {
                // no biometrics
                biometricError = true
            }
        }
    }
}
