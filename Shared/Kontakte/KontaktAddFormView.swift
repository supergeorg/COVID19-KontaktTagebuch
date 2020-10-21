//
//  KontaktAddFormView.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 17.08.20.
//

import SwiftUI

struct SelectionItemView: View {
    @Binding var kontaktPersonen: Set<Person>
    var person: Person
    
    var body: some View {
        Label(person.isgroup ? (person.groupname ?? "kein GN") : "\(person.vorname ?? "kein VN") \(person.nachname ?? "kein NN")", systemImage: kontaktPersonen.contains(person) ? "checkmark.circle" : "circle")
            .onTapGesture {
                if kontaktPersonen.contains(person) {
                    kontaktPersonen.remove(person)
                } else {
                    kontaktPersonen.insert(person)
                }
            }
    }
}

struct KontaktAddFormView: View {
    @State private var kontaktTitle = ""
    @State private var kontaktDatum: Date = Date()
    @State private var kontaktPersonen = Set<Person>()
    @State private var kontaktIsOutdoor: Bool = false
    @State private var kontaktDuration: Double = 900.0
    @State private var kontaktTyp: KontaktModes = .privateMeet
    @State private var kontaktIsKnownPerson: Bool = false
    @Binding var isShown: Bool
    
    @FetchRequest(fetchRequest: PersistentStore.shared.fetchPersonen()) var personen: FetchedResults<Person>
    
    private func saveKontakt() {
        PersistentStore.shared.addKontakt(title: kontaktTitle, date: kontaktDatum, isOutdoor: kontaktIsOutdoor, duration: kontaktDuration, kontaktPersonen: kontaktPersonen, type: kontaktTyp)
    }
    
    var body: some View {
        NavigationView() {
            Form {
                Section(header: Text("Allgemeines")){
                    HStack{
                        Image(systemName: "text.alignleft")
                        TextField("Beschreibung", text: $kontaktTitle)
                    }
                }
                Section(header: Text("Zeit")){
                    HStack {
                        Image(systemName: "calendar")
                        DatePicker("Datum", selection: $kontaktDatum)
                    }
                    VStack(alignment:.leading){
                        HStack {
                            Image(systemName: "clock")
                            Stepper("Dauer: \(formatDuration(duration2format: kontaktDuration))", onIncrement: {kontaktDuration = kontaktDuration + 900.0}, onDecrement: {kontaktDuration = kontaktDuration - 900.0})
                                .animation(.none)
                        }
                        // 900 = 15min, 86400 = 24h
                        Slider(value: $kontaktDuration, in: 900...86400, step: 900, minimumValueLabel: Text("15 Minuten"), maximumValueLabel: Text("1 Tag"), label: {Text("Dauer")})
                    }
                }
                Section(header: Text("Personen")){
                    HStack {
                        Image(systemName: "person.fill.questionmark")
                        Toggle("Bekannte Person", isOn: $kontaktIsKnownPerson)
                    }
                    if kontaktIsKnownPerson {
                        List(){
                            ForEach(personen, id: \.id) {person in
                                SelectionItemView(kontaktPersonen: $kontaktPersonen, person: person)
                            }
                        }
                    }
                }
                Section(header: Text("Art des Kontakts")){
                    HStack {
                        Image(systemName: "questionmark.folder")
                        Picker(selection: $kontaktTyp, label: Text("Kontakttyp")) {
                            ForEach(KontaktModes.allCases, id:\.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                    }
                    HStack {
                        Image(systemName: "sun.max")
                        Toggle("Draußen", isOn: $kontaktIsOutdoor)
                    }
                }
            }
            .animation(.default)
            .navigationBarTitle("Kontakt hinzufügen")
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        self.isShown = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kontakt speichern") {
                        saveKontakt()
                        self.isShown = false
                    }//.disabled()
                }
            })
        }
    }
}

struct KontaktAddFormView_Previews: PreviewProvider {
    static var previews: some View {
        KontaktAddFormView(isShown: Binding.constant(true))
    }
}
