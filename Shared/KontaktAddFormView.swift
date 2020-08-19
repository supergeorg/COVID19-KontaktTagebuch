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
    @State private var title = ""
    @State private var datum: Date = Date()
    @State private var kontaktPersonen = Set<Person>()
    @State private var isOutdoor: Bool = false
    @State private var duration: Double = 900.0
    @State private var contactType: enum_contactType = .privatemeet
    @Binding var isShown: Bool
    
    @FetchRequest(fetchRequest: PersistentStore.shared.fetchPersonen()) var personen: FetchedResults<Person>
    
    private func saveKontakt() {
        PersistentStore.shared.addKontakt(title: title, date: datum, isOutdoor: isOutdoor, duration: duration, kontaktPersonen: kontaktPersonen)
    }
    
    var body: some View {
        VStack{
            HStack{
                Button("Abbrechen") {
                    self.isShown = false
                }
                Spacer()
                Button("Kontakt speichern") {
                    saveKontakt()
                    self.isShown = false
                }
            }.padding()
            Form {
                Section(header: Text("Allgemeines")){
                    TextField("Beschreibung", text: $title)
                }
                Section(header: Text("Zeit")){
                    DatePicker("Datum", selection: $datum)
                    VStack(alignment:.leading){
                        Stepper("Dauer: \(formatDuration(duration2format: duration))", onIncrement: {duration = duration + 900.0}, onDecrement: {duration = duration - 900.0})
                        // 900 = 15min, 86400 = 24h
                        Slider(value: $duration, in: 900...86400, step: 900, minimumValueLabel: Text("15 Minuten"), maximumValueLabel: Text("1 Tag"), label: {Text("Dauer")})
                    }
                }
                Section(header: Text("Personen")){
                    ForEach(personen, id: \.id) {person in
                        SelectionItemView(kontaktPersonen: $kontaktPersonen, person: person)
                    }
                }
                Section(header: Text("Art des Kontakts")){
                    //                    Picker(selection: $contactType, label: Text("Kontakttyp")) {
                    //                        Text("Privates Treffen").tag(enum_contactType.privatemeet)
                    //                        Text("Ausgehen / Essen").tag(enum_contactType.eatingout)
                    //                        Text("Treffen").tag(enum_contactType.gathering)
                    //                        Text("Sport").tag(enum_contactType.sport)
                    //                    }.pickerStyle(WheelPickerStyle())
                    Toggle("Draußen", isOn: $isOutdoor)
                }
            }
        }
        .navigationBarTitle("Kontakt hinzufügen")
    }
}

struct KontaktAddFormView_Previews: PreviewProvider {
    static var previews: some View {
        KontaktAddFormView(isShown: Binding.constant(true))
    }
}
