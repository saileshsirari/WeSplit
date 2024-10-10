//
//  CupcakeCorner.swift
//  WeSplit
//
//  Created by sailesh sirari on 09/10/24.
//

import Foundation
import SwiftUI
@Observable
class Order : Codable {
    static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]
    var name = ""
    var streetAddress = ""
    var city = ""
    var zip = ""
    var type = 0
    var quantity = 3
    
    var extraFrosting = false
    var addSprinkles = false
    
    var specialRequestEnabled = false {
        didSet {
            if specialRequestEnabled == false {
                extraFrosting = false
                addSprinkles = false
            }
        }
    }
    
    var hasValidAddress: Bool {
        if name.isEmpty || streetAddress.isEmpty || city.isEmpty || zip.isEmpty {
            return false
        }
        if(name.trimmingCharacters(in: .whitespacesAndNewlines).count==0){
            return false
        }
        
        if(streetAddress.trimmingCharacters(in: .whitespacesAndNewlines).count==0){
            return false
        }
        
        if(city.trimmingCharacters(in: .whitespacesAndNewlines).count==0){
            return false
        }
        
        
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "address")
        }
        
        return true
    }
    
    var cost: Decimal {
        // $2 per cake
        var cost = Decimal(quantity) * 2
        
        // complicated cakes cost more
        cost += Decimal(type) / 2
        
        // $1/cake for extra frosting
        if extraFrosting {
            cost += Decimal(quantity)
        }
        
        // $0.50/cake for sprinkles
        if addSprinkles {
            cost += Decimal(quantity) / 2
        }
        
        return cost
    }
    
    enum CodingKeys: String, CodingKey {
        case _type = "type"
        case _quantity = "quantity"
        case _specialRequestEnabled = "specialRequestEnabled"
        case _extraFrosting = "extraFrosting"
        case _addSprinkles = "addSprinkles"
        case _name = "name"
        case _city = "city"
        case _streetAddress = "streetAddress"
        case _zip = "zip"
    }
}

struct AddressView: View {
    @Bindable var order: Order
    
    init(order: Order) {
        self.order = order
        if let savedItems = UserDefaults.standard.data(forKey: "address") {
            if let decodedItems = try? JSONDecoder().decode(Order.self, from: savedItems) {
                self.order = decodedItems
                return
            }
        }
      
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section {
                    TextField("Name", text: $order.name)
                    TextField("Street Address", text: $order.streetAddress)
                    TextField("City", text: $order.city)
                    TextField("Zip", text: $order.zip)
                }
                
                Section {
                    NavigationLink("Check out") {
                        CheckoutView(order: order)
                    }
                } .disabled(order.hasValidAddress == false)
            }
            .navigationTitle("Delivery details")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
    
}

struct CheckoutView: View {
    var order: Order
    @State private var confirmationMessage = ""
    @State var wrrorMessage = ""
    @State private var showError = false
    @State private var showingConfirmation = false
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: "https://hws.dev/img/cupcakes@3x.jpg"), scale: 3) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 233)
                
                Text("Your total is \(order.cost, format: .currency(code: "USD"))")
                    .font(.title)
                
                Button("Place Order", action: {
                    Task {
                        do{
                            try await placeOrder()
                        }catch  MyError.runtimeError (let error){
                            wrrorMessage = error
                            showError = true
                        }catch {
                            wrrorMessage = "Error "
                            showError = true
                            
                        }
                    }
                })
                .padding()
            }
        }
        .navigationTitle("Check out")
        .navigationBarTitleDisplayMode(.inline)
        .scrollBounceBehavior(.basedOnSize)
        
        .alert("Thank you!", isPresented: $showingConfirmation) {
            Button("OK") {
                
            }
        } message: {
            Text(confirmationMessage)
        }
        .alert("Error !", isPresented: $showError) {
            Button("OK") {
                
            }
        } message: {
            Text(wrrorMessage)
        }
    }
    
    func placeOrder() async throws {
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            return
        }
        
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let decodedOrder = try JSONDecoder().decode(Order.self, from: data)
            confirmationMessage = "Your order for \(decodedOrder.quantity)x \(Order.types[decodedOrder.type].lowercased()) cupcakes is on its way!"
            showingConfirmation = true
        } catch {
            print("Checkout failed: \(error.localizedDescription)")
            throw MyError.runtimeError("Checkout failed: \(error.localizedDescription)")
        }
    }
}
enum MyError: Error {
    case runtimeError(String)
}
struct CupcakeCorner :  View {
    
    @State private var order = Order()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Select your cake type", selection: $order.type) {
                        ForEach(Order.types.indices, id: \.self) {
                            Text(Order.types[$0])
                        }
                    }
                    
                    Stepper("Number of cakes: \(order.quantity)", value: $order.quantity, in: 3...20)
                }
                Section {
                    Toggle("Any special requests?", isOn: $order.specialRequestEnabled)
                    
                    if order.specialRequestEnabled {
                        Toggle("Add extra frosting", isOn: $order.extraFrosting)
                        
                        Toggle("Add extra sprinkles", isOn: $order.addSprinkles)
                    }
                }
                
                Section {
                    NavigationLink("Delivery details") {
                        AddressView(order: order)
                    }
                }
            }
            .navigationTitle("Cupcake Corner")
        }
    }
}


#Preview {
    CupcakeCorner()
}
