//
//  KontaktDetailView.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 17.08.20.
//

import SwiftUI

struct KontaktDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment (\.managedObjectContext) var moc
    @State private var editMode : EditMode = .inactive
    
    var kontakt: Kontakt
    var isReadOnly: Bool
    
    @State private var kontaktTitle: String
    @State private var kontaktDatum: Date
    @State private var kontaktPersonen : Set<Person>
    @State private var kontaktIsOutdoor: Bool
    @State private var kontaktDuration: Double
    @State private var kontaktTyp: KontaktModes
    
    @State private var showDeleteSheet: Bool = false
    
    private func saveChange() {
        if moc.hasChanges {
            do {
                try moc.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private var deleteContactAS: ActionSheet {
        ActionSheet(title: Text("Kontakt löschen"),
                    message: Text("Mit dieser Aktion wird der entsprechende Kontakt gelöscht. Der Vorgang ist irreversibel."),
                    buttons: [
                        .destructive(Text("Löschen"), action: {
                            PersistentStore.shared.deleteKontakt(kontakt: kontakt)
                            self.presentationMode.wrappedValue.dismiss()
                        }),
                        .cancel()
                    ]
        )
    }
    
    init(kontakt: Kontakt, isReadOnly: Bool) {
        self.kontakt = kontakt
        self.isReadOnly = isReadOnly
        self._kontaktTitle = State(initialValue: kontakt.title ?? "")
        self._kontaktDatum = State(initialValue: kontakt.date ?? Date())
        self._kontaktPersonen = State(initialValue: (kontakt.personen ?? Set<Person>() as NSSet) as! Set<Person>)
        self._kontaktIsOutdoor = State(initialValue: kontakt.outdoor)
        self._kontaktDuration = State(initialValue: kontakt.duration)
        self._kontaktTyp = State(initialValue: KontaktModes(rawValue: kontakt.type ?? "Privat") ?? KontaktModes.privateMeet)
    }
    
    private struct KontaktPersonView: View {
        @FetchRequest(fetchRequest: PersistentStore.shared.fetchPersonen()) var personen: FetchedResults<Person>
        var kontaktpersonen: Set<Person>
        
        @Binding var editMode: EditMode
        @Binding var kontaktPersonen: Set<Person>
        
        var body: some View {
            Section(header: Text("Personen / Gruppen")){
                if editMode == EditMode.active {
                    List(){
                        ForEach(personen, id: \.id) {person in
                            SelectionItemView(kontaktPersonen: $kontaktPersonen, person: person)
                        }
                    }
                } else {
                    if kontaktpersonen.count == 0 {
                        Label("Keine Personen für diesen Kontakt aufgezeichnet.", systemImage: "xmark.circle")
                    }
                    ForEach(Array(kontaktpersonen), id: \.self) {person in
                        List(){
                            HStack{
                                if person.isgroup {
                                    Label(person.groupname ?? "Error: Groupname", systemImage: "person.3")
                                } else {
                                    Label("\(person.vorname ?? "Error: Vorname") \(person.nachname ?? "Error: Nachname")", systemImage: "person")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Allgemeines")){
                if editMode == EditMode.active {
                    HStack {
                        Image(systemName: "textbox")
                        TextField("Beschreibung", text: $kontaktTitle)
                    }
                } else {
                    Label(kontakt.title ?? "kein Titel", systemImage: "textbox")
                }
            }
            Section(header: Text("Zeit")){
                if editMode == EditMode.active {
                    HStack {
                        Image(systemName: "calendar")
                        DatePicker("Datum", selection: $kontaktDatum)
                    }
                    VStack(alignment: .leading){
                        HStack {
                            Image(systemName: "clock")
                            Stepper("Dauer: \(formatDuration(duration2format: kontaktDuration))", onIncrement: {kontaktDuration = kontaktDuration + 900.0}, onDecrement: {kontaktDuration = kontaktDuration - 900.0})
                        }
                        // 900 = 15min, 86400 = 24h
                        Slider(value: $kontaktDuration, in: 900...86400, step: 900, minimumValueLabel: Text("15 Minuten"), maximumValueLabel: Text("1 Tag"), label: {Text("Dauer")})
                    }
                } else {
                    Label(formatDate(date2format: kontakt.date), systemImage: "calendar")
                    Label(formatDuration(duration2format: kontakt.duration), systemImage: "clock")
                }
            }
            if kontakt.personen?.count ?? 0 > 0 {
                KontaktPersonView(kontaktpersonen: kontakt.personen as! Set<Person>, editMode: $editMode, kontaktPersonen: $kontaktPersonen)
            }
            Section(header: Text("Art des Kontakts")){
                if editMode == EditMode.active {
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
                } else {
                    Label("Art des Kontakts: \(kontakt.type ?? "unbekannt")", systemImage: "questionmark.folder")
                    if kontakt.outdoor {
                        Label("Kontakt fand Draußen statt.", systemImage: "checkmark.shield")
                            .foregroundColor(.green)
                    } else {
                        Label("Kontakt fand in einem Innenraum statt.", systemImage: "xmark.shield")
                            .foregroundColor(.red)
                    }
                }
            }
            if !isReadOnly && editMode == EditMode.inactive {
                Button(action: {
                    showDeleteSheet = true
                }, label: {
                    Label("Kontakt löschen", systemImage: "trash")
                        .foregroundColor(.red)
                }).actionSheet(isPresented: $showDeleteSheet, content: {
                    self.deleteContactAS
                })
            }
        }
        .animation(.default)
        .navigationBarTitle("Kontakt")
        .toolbar(content: {
            ToolbarItem(placement: .automatic) {
                HStack{
                    if !isReadOnly {
                        if editMode == EditMode.active {
                            Button(action: {editMode = EditMode.inactive}) {Text("Abbrechen")}
                        }
                        Button(action: {
                            if editMode == EditMode.inactive {
                                editMode = EditMode.active
                            } else {
                                kontakt.title = kontaktTitle
                                kontakt.date = kontaktDatum
                                kontakt.personen = kontaktPersonen as NSSet
                                kontakt.outdoor = kontaktIsOutdoor
                                kontakt.duration = kontaktDuration
                                saveChange()
                                editMode = EditMode.inactive
                            }
                        }) {
                            Text(editMode == EditMode.active ? "Fertig" : "Bearbeiten")
                        }
                    }
                }
            }
        })
        .environment(\.editMode, $editMode)
    }
}

struct KontaktDetailView_Previews: PreviewProvider {
    static var previews: some View {
        KontaktDetailView(kontakt: Kontakt(), isReadOnly: false)
    }
}
