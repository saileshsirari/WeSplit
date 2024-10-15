//
//  ContentView.swift
//  WeSplit
//
//  Created by sailesh sirari on 02/10/24.
//

import SwiftUI
import SwiftData
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins
import StoreKit


struct ImageFilterContentView : View {
    
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingFilters = false
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    
    let context = CIContext()
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                PhotosPicker(selection: $selectedItem) {
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Import a photo to get started"))
                    }
                }.onChange(of: selectedItem, loadImage)


                Spacer()

                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity, applyProcessing)
                }
                .padding(.vertical)

                HStack {
                    Button("Change Filter", action: changeFilter)


                    Spacer()

                    if let processedImage {
                        ShareLink(item: processedImage, preview: SharePreview("Instafilter image", image: processedImage))
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                Button("Edges") { setFilter(CIFilter.edges()) }
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                Button("Vignette") { setFilter(CIFilter.vignette()) }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    @MainActor  func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
        filterCount += 1

        if filterCount >= 3 {
            requestReview()
        }
    }
    func changeFilter() {
        showingFilters = true

    }
    
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }

            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }

        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }

        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
}
struct SwiftDataContentView: View {
    
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<User> { user in
        if user.name.localizedStandardContains("R") {
            if user.city == "London" {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }, sort: \User.name)
    
    var users: [User]
    
    @State private var path = [User]()
    
    
    var body: some View {
        NavigationStack(path: $path) {
            List(users) { user in
                NavigationLink(value: user) {
                    Text(user.name)
                }
            }
            .navigationTitle("Users")
            .navigationDestination(for: User.self) { user in
                EditUserView(user: user)
            }.toolbar {
                
                
                Button("Add Samples", systemImage: "plus") {
                    try? modelContext.delete(model: User.self)
                    let first = User(name: "Ed Sheeran", city: "London", joinDate: .now.addingTimeInterval(86400 * -10))
                    let second = User(name: "Rosa Diaz", city: "New York", joinDate: .now.addingTimeInterval(86400 * -5))
                    let third = User(name: "Roy Kent", city: "London", joinDate: .now.addingTimeInterval(86400 * 5))
                    let fourth = User(name: "Johnny English", city: "London", joinDate: .now.addingTimeInterval(86400 * 10))
                    
                    modelContext.insert(first)
                    modelContext.insert(second)
                    modelContext.insert(third)
                    modelContext.insert(fourth)
                }
            }
        }
    }
    
    
}
struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: [
        SortDescriptor(\Book.title),
        SortDescriptor(\Book.author)
    ]) var books: [Book]
    
    @State private var showingAddScreen = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(books) { book in
                    NavigationLink(value: book) {
                        HStack {
                            EmojiRatingView(rating: book.rating)
                                .font(.largeTitle)
                            //
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)
                                
                                Text(book.author)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteBooks)
            }
            .navigationTitle("Bookworm")
            .navigationDestination(for: Book.self) { book in
                DetailView(book: book)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Book", systemImage: "plus") {
                        showingAddScreen.toggle()
                    }
                }
            }
            .sheet(isPresented: $showingAddScreen) {
                AddBookView()
            }
        }
    }
    
    func deleteBooks(at offsets: IndexSet) {
        for offset in offsets {
            let book = books[offset]
            modelContext.delete(book)
        }
    }
}

#Preview {
    ContentView()
}
func addHabit(_ title:String,_ desc:String ) ->Bool {
    let answer = title.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // exit if the remaining string is empty
    guard answer.count > 0 else { return false}
    
    let desc = desc.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // exit if the remaining string is empty
    guard desc.count > 0 else { return false}
    
    
    return true
    
    
}
struct Habit : Hashable,Identifiable, Codable, Equatable{
    var id = UUID()
    var title = ""
    var description = ""
    var completed = false
}
@Observable
class HabitClass {
    
    
    
    var list  = [ Habit](){
        didSet{
            if let encoded = try? JSONEncoder().encode(list) {
                UserDefaults.standard.set(encoded, forKey: "Activities")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Activities") {
            if let decodedItems = try? JSONDecoder().decode([Habit].self, from: savedItems) {
                list = decodedItems
                return
            }
        }
        
        list = []
    }
}
struct Habits:View {
    
    
    
    @State
    private var habitClass :HabitClass = HabitClass()
    
    
    
    @State private var showingSheet = false
    
    struct SheetView: View {
        @Environment(\.dismiss) var dismiss
        
        
        @State var habit :Habit = Habit(title: "",description: "")
        @State
        var habitClass : HabitClass
        
        var body: some View {
            Section("Enter your activity details ") {
                
                TextField("Enter activity title",text: $habit.title)
                    .padding()
                TextField("Enter activity desciption",text: $habit.description)
                    .padding()
                
                Button("Done") {
                    if( addHabit(habit.title,habit.description) ){
                        habitClass.list.append(habit)
                        
                    }
                    dismiss()
                }
                .font(.title)
                .padding()
            }
        }
    }
    @State private var complete: Bool = false
    var body: some View {
        NavigationStack{
            
            Button("Add an activity"){
                showingSheet.toggle()
            }.sheet(isPresented: $showingSheet) {
                SheetView(habitClass: habitClass)
            }
            // print(habitClass.list[1].title)
            
            
            List(habitClass.list){habit in
                habitListItem(habit: habit)
            }.navigationDestination(for: Habit.self) { habit in
                DestinationView( habit: habit,habitClass: habitClass)
                
                
            }.navigationTitle("Habits")
                .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}

struct DestinationView: View {
    
    
    var habit: Habit
    
    @State var habitClass  :  HabitClass
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button("Finish  \(habit.title)"){
            // habit = Habit.co
            
            
            if let ind =  habitClass.list.firstIndex(of: habit){
                if(ind != -1){
                    habitClass.list.remove(at: ind)
                }
                dismiss()
                
            }
            
        }
    }
}
struct MoonProject :  View {
    let astronauts:[String:Astronaut] = Bundle.main.decode("astronauts.json")
    let missions: [Mission] = Bundle.main.decode("missions.json")
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    @State private var showAsList = true
    var body: some View {
        NavigationStack {
            
            ScrollView {
                List(missions){ mission in
                    listItem(mission,astronauts: astronauts)
                }
                .listStyle(.plain)
                .frame(minHeight: 200 * 3,maxHeight:.infinity)
                .listRowBackground(Color.darkBackground)
                .navigationDestination(for: Mission.self) { mission in
                    MissionView(mission: mission, astronauts: astronauts)
                }
                
                if(showAsList){
                    
                    
                    
                    /* LazyVStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                     ForEach(missions) { mission in
                     listItem(mission,astronauts: astronauts)
                     }
                     })*/
                    
                }else{
                    LazyVGrid(columns: columns) {
                        missionUi(missions: missions,astronauts: astronauts)
                    }
                }
                
                
            }
            .navigationTitle("Moonshot")
            .background(.darkBackground)
            .preferredColorScheme(.dark)
            .toolbar {
                Button(showAsList ? "Grid":"List") {
                    showAsList.toggle()
                }
            }
            
            
        }
    }
}
func listItem(_ mission: Mission, astronauts: [String: Astronaut]) -> some View {
    return NavigationLink(value: mission) {
        VStack {
            Image(mission.image)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding()
            
            VStack {
                Text(mission.displayName)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(mission.formattedLaunchDate)
                
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(.lightBackground)
        }.clipShape(.rect(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.lightBackground)
            )
        
    }
}

func habitListItem(habit: Habit) -> some View {
    return NavigationLink(value: habit) {
        
        VStack {
            Text(habit.title)
                .font(.headline)
                .foregroundStyle(.black)
            Text(habit.description)
                .font(.caption)
                .foregroundStyle(.black)
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity)
        
    }
}

struct missionUi : View {
    let missions: [Mission]
    let astronauts:[String:Astronaut]
    var body: some View {
        ForEach(missions) { mission in
            listItem(mission,astronauts: astronauts)
        }
    }
}
struct WordScramble: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    let people = ["Finn", "Leia", "Luke", "Rey"]
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                // If we are here everything has worked, so we can exit
                return
            }
        }
        
        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation(.spring) {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    @State private var enabled = false
    @State private var dragAmount = CGSize.zero
    let letters = Array("Hello SwiftUI")
    
    var body: some View {
        NavigationStack {
            
            HStack(spacing: 0) {
                ForEach(0..<letters.count, id: \.self) { num in
                    Text(String(letters[num]))
                        .padding(5)
                        .font(.title)
                        .background(enabled ? .blue : .red)
                        .offset(dragAmount)
                        .animation(.linear.delay(Double(num) / 20), value: dragAmount)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { dragAmount = $0.translation }
                    .onEnded { _ in
                        dragAmount = .zero
                        enabled.toggle()
                    }
            )
            
            Button("Tap Me") {
                enabled.toggle()
            }
            .frame(width: 20, height: 20)
            .background(enabled ? .blue : .red)
            .animation(.default, value: enabled)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: enabled ? 60 : 0))
            .animation(.spring(duration: 1, bounce: 0.6), value: enabled)
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
            
        }
    }
}
struct BetterSleepView: View {
    static var  defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    
    
    func calculateBedtime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
    }
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount,in: 4 ... 12, step: 0.25)
                }
                Text("Daily coffee intake")
                    .font(.headline)
                
                Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
                
                DatePicker("Please enter a date", selection: $wakeUp ,  in: Date.now...,displayedComponents: .hourAndMinute).labelsHidden()
                
            }.navigationTitle("BetterRest")
                .toolbar {
                    Button("Calculate", action: calculateBedtime)
                }
        }
    }
    
    
}
struct SpitWiseView: View {
    @State private var checkAmount = 0.0
    @State private var numberOfPeople = 2
    @State private var tipPercentage = 20
    @FocusState private var amountIsFocused: Bool
    
    let tipPercentages = [10, 15, 20, 25, 0]
    var totalPerPerson: Double {
        let peopleCount = Double(numberOfPeople + 2)
        let tipSelection = Double(tipPercentage)
        
        let tipValue = checkAmount / 100 * tipSelection
        let grandTotal = checkAmount + tipValue
        let amountPerPerson = grandTotal / peopleCount
        
        return amountPerPerson
    }
    var totalAmount: Double {
        let peopleCount = Double(numberOfPeople + 2)
        let tipSelection = Double(tipPercentage)
        
        let tipValue = checkAmount / 100 * tipSelection
        let grandTotal = checkAmount + tipValue
        
        return grandTotal
    }
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Amount", value: $checkAmount, format: .currency(code: Locale.current.currency?.identifier ?? "USD")) .keyboardType(.decimalPad).focused($amountIsFocused)
                    
                    
                }
                Section {
                    Text(checkAmount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }
                Picker("Number of people", selection: $numberOfPeople) {
                    ForEach(2 ..< 100) {
                        Text("\($0) people")
                    }
                }
                .pickerStyle(.navigationLink)
                
                Section("How much tip do you want to leave?") {
                    Picker("Tip percentage",selection: $tipPercentage){
                        ForEach(0 ..< 101) {
                            Text($0, format: .percent)
                        }
                    }.pickerStyle(.navigationLink)
                }
                
                Section ( "Total "){
                    Text(totalAmount, format: .currency(code: Locale.current.currency?.identifier ?? "USD")).background(tipPercentage == 0 ? .red : .white)
                }
                Section ( "Amount per person"){
                    Text(totalPerPerson, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }
                
            }.navigationTitle("Split Wise").toolbar {
                if amountIsFocused {
                    Button("Done") {
                        amountIsFocused = false
                    }
                }
            }
        }
    }
    
}
struct FlagImage: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(.capsule)
            .shadow(radius: 5)
    }
}
extension View {
    func FlagImageStyle() -> some View {
        modifier(FlagImage())
    }
}
struct guessTheFlag :  View {
    @State var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"]
    @State var correctAnswer = Int.random(in: 0...2)
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var score = 0
    @State var countQuestions  = 0
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
    
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct"
            score += 1
        } else {
            scoreTitle = "Wrong! That's the flag of \(countries[number])"
        }
        countQuestions += 1
        if(countQuestions > countries.count/2){
            countQuestions = 0
            score = 0
        }
        showingScore = true
    }
    
    
    
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3),
            ], center: .top, startRadius: 200, endRadius: 400)
            .ignoresSafeArea()
            VStack {
                Text("Guess the Flag")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Spacer()
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            // flag was tapped
                            flagTapped( number)
                        } label: {
                            Image(countries[number]).FlagImageStyle()
                            
                        }
                    }
                }.frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(.regularMaterial)
                    .clipShape(.rect(cornerRadius: 20))
                Spacer()
                Spacer()
                Text("Score: \(score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                
                Spacer()
            }.padding()
            
        }.alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            if (countQuestions == countries.count / 2 ) {
                // self.askQuestion()
                Text("Your final score is \(score) restarting game")
                
            }else{
                Text("Your score is \(score)")
            }
        }
        
    }
}
struct ViewsAndModifiers : View {
    var body: some View {
        Text (" Hello World!")
    }
}
struct unitConvertView :  View {
    @State private var temperature = 0.0
    @State private var unit = 2
    @State private var sourceUnit = "@C"
    @State private var sourceTemp =  0.0
    @FocusState private var amountIsFocused: Bool
    
    let units = ["@C","@F"]
    var srcTemprature: Double {
        let sourceUnitSelected = sourceUnit
        if(sourceUnitSelected == "@C" ){
            
            
            
        }else{
            
        }
        return (sourceTemp)
        
    }
    
    var body: some View {
        NavigationStack {
            Form {
                HStack{
                    
                    TextField("Source temp", value: $sourceTemp, format: .number)
                    
                    
                    Picker("Source Unit", selection: $sourceUnit) {
                        ForEach(units,id: \.self) {
                            Text("\($0)")
                        }
                    }
                    
                    
                    
                }
                HStack(alignment: .lastTextBaseline){
                    
                    Text(sourceTemp, format: .number).frame(minWidth: 10).frame(maxWidth: .infinity, alignment: .leading)
                    
                    Picker("Destination Unit", selection: $sourceUnit) {
                        ForEach(units,id: \.self) {
                            Text("\($0)")
                        }
                    }.frame(alignment: .trailing)
                    
                }
                
            }.navigationTitle("Temperature convert").toolbar {
                if amountIsFocused {
                    Button("Done") {
                        amountIsFocused = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
