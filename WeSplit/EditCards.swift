//
//  EditCards.swift
//  WeSplit
//
//  Created by sailesh sirari on 22/10/24.
//

import SwiftUI
extension VerticalAlignment {
    struct MidAccountAndName: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.top]
        }
    }

    static let midAccountAndName = VerticalAlignment(MidAccountAndName.self)
}

struct ThreeD: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(1..<20) { num in
                    Text("Number \(num)")
                        .font(.largeTitle)
                        .padding()
                        .background(.red)
                        .frame(width: 200, height: 200)
                        .visualEffect { content, proxy in
                            content
                                .rotation3DEffect(.degrees(-proxy.frame(in: .global).minX) / 8, axis: (x: 0, y: 1, z: 0))
                        }

                }
            }.scrollTargetLayout()
         
        }   .scrollTargetBehavior(.viewAligned)
    }
}
struct EditCards: View {
    @Environment(\.dismiss) var dismiss
    @State private var cards = [Card]()
    @State private var newPrompt = ""
    @State private var newAnswer = ""
    struct OuterView: View {
        var body: some View {
            VStack {
                Text("Top")
                InnerView()
                    .background(.green)
                Text("Bottom")
            }
        }
    }
    init() {
        initColors()
    }
    struct InnerView: View {
        var body: some View {
            HStack {
                Text("Left")
                GeometryReader { proxy in
                    Text("Center")
                        .background(.blue)
                        .onTapGesture {
                            print("Global center: \(proxy.frame(in: .global).midX) x \(proxy.frame(in: .global).midY)")
                            print("Custom center: \(proxy.frame(in: .named("Custom")).midX) x \(proxy.frame(in: .named("Custom")).midY)")
                            print("Local center: \(proxy.frame(in: .local).midX) x \(proxy.frame(in: .local).midY)")
                        }
                }
                .background(.orange)
                Text("Right")
            }
        }
    }
    var colors: [Color]  = Array()
    mutating func initColors(){
        (1...7).forEach{ i in
            colors.append(Color(hue: Double.random(in: 0.1...1.0), saturation: 1, brightness: 1, opacity: 1))
        }
    }
   
    
    var body: some View {
        
        //ThreeD()
        
       
        
        GeometryReader { fullView in
            ScrollView(.vertical) {
                ForEach(0..<50) { index in
                    GeometryReader { proxy in
                        Text("Row #\(index)")
                        
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .background(colors[ abs(Int(proxy.frame(in: .global).minY )) % 7])
                            .rotation3DEffect(.degrees(proxy.frame(in: .global).minY - fullView.size.height / 2) / 5, axis: (x: 0, y: 1, z: 0))
                            .opacity(proxy.frame(in: .global).minY>200 ? 1 : 0)
                           
                            .scaleEffect( proxy.frame(in: .global).minY/490)
                           
                    }
                    .frame(height: 40)
                }
            }
        }
    
          
       
       /*
        OuterView()
                 .background(.red)
                 .coordinateSpace(name: "Custom")
        ScrollView{
            
            Text("Hello, world!")
                   .offset(x: 100, y: 100)
                   .background(.red)
            
           
            
            Text("Hello, world!")
                .background(.red)
                .position(x: 100, y: 100)
            
            Text("Hello, world!")
                .position(x: 100, y: 100)
                .background(.red)
            
            
            
            
            VStack(alignment: .leading) {
                ForEach(0..<10) { position in
                    Text("Number \(position)")
                        .alignmentGuide(.leading) { _ in Double(position) * -10 }
                }
            }
            .background(.red)
            .frame(width: 400, height: 400)
            .background(.blue)
            
            VStack(alignment: .leading) {
                Text("Hello, world!")
                    .alignmentGuide(.leading) { d in d[.trailing] }
                Text("This is a longer line of text")
            }
            .padding()
            .background(.white)
            .frame(width: 300, height: 300)
            .background(.blue)
            .frame(width: 350, height: 350)
            .background(.yellow)
            
        }
                
        NavigationStack {
            List {
                Section("Add new card") {
                    TextField("Prompt", text: $newPrompt)
                    TextField("Answer", text: $newAnswer)
                    Button("Add Card", action: addCard)
                }

                Section {
                    ForEach(0..<cards.count, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text(cards[index].prompt)
                                .font(.headline)
                            Text(cards[index].answer)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: removeCards)
                }
            }
            .navigationTitle("Edit Cards")
            .toolbar {
                Button("Done", action: done)
            }
            .onAppear(perform: loadData)
        }*/
    }

    func done() {
        dismiss()
    }

    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
    }

    func saveData() {
        if let data = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(data, forKey: "Cards")
        }
    }

    func addCard() {
        let trimmedPrompt = newPrompt.trimmingCharacters(in: .whitespaces)
        let trimmedAnswer = newAnswer.trimmingCharacters(in: .whitespaces)
        guard trimmedPrompt.isEmpty == false && trimmedAnswer.isEmpty == false else { return }

        let card = Card(prompt: trimmedPrompt, answer: trimmedAnswer)
        cards.insert(card, at: 0)
        saveData()
        newPrompt = ""
        newAnswer = ""
    }

    func removeCards(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
        saveData()
    }
}

#Preview {
    EditCards()
}
