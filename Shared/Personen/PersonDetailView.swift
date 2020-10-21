//
//  PersonView.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 17.08.20.
//

import SwiftUI

struct PersonDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment (\.managedObjectContext) var moc
    @State private var editMode : EditMode = .inactive
    
    @State private var personVorname: String
    @State private var personNachname: String
    @State private var groupName: String
    
    var person: Person
    @State var isFavourite: Bool
    @State private var showDeleteSheet: Bool = false
    var isReadOnly: Bool
    @State private var somethingChanged: Bool = false
    
    init(person: Person, isFavourite: Bool, isReadOnly: Bool) {
        self.person = person
        self.isReadOnly = isReadOnly
        self._isFavourite = State(initialValue: isFavourite)
        self._groupName = State(initialValue: person.groupname ?? "")
        self._personVorname = State(initialValue: person.vorname ?? "")
        self._personNachname = State(initialValue: person.nachname ?? "")
    }
    
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
    
    private var deletePersonAS: ActionSheet {
        ActionSheet(title: Text("Person löschen"),
                    message: Text("Mit dieser Aktion wird die entsprechende Person gelöscht. Der Vorgang ist irreversibel."),
                    buttons: [
                        .destructive(Text("Löschen"), action: {
                            PersistentStore.shared.deletePerson(person: person)
                            self.presentationMode.wrappedValue.dismiss()
                        }),
                        .cancel()
                    ]
        )
    }
    
    var body: some View {
        Form {
            if person.isgroup{
                Section(header: Text("Gruppendaten")){
                    if editMode == EditMode.active {
                        TextField("Gruppenname", text: $groupName)
                    } else {
                        Label(person.groupname ?? "kein Gruppenname", systemImage: "person.3")
                    }
                }
            } else {
                Section(header: Text("Persönliche Daten")){
                    if editMode == EditMode.active {
                        TextField("Vorname", text: $personVorname)
                        TextField("Nachname", text: $personNachname)
                    } else {
                        Label("\(person.vorname ?? "kein Vorname") \(person.nachname ?? "kein Nachname")", systemImage: "person")
                    }
                }
            }
            Section(header: Text("Kontakte")){
                if person.kontakte?.count == 0 {
                    Label("Bisher kein aufgezeichneter Kontakt.", systemImage: "xmark.circle")
                }
                ForEach(Array((person.kontakte ?? Set<Kontakt>() as NSSet) as! Set<Kontakt>), id: \.self) {kontakt in
                    NavigationLink(destination: KontaktDetailView(kontakt: kontakt, isReadOnly: isReadOnly)) {
                        KontaktItemView(kontakt: kontakt)
                    }
                }
            }
            if !isReadOnly {
                Section(header: Text("Einstellungen")){
                    HStack {
                        Image(systemName: "star")
                        Toggle(person.isgroup ? "Favorisierte Gruppe" : "Favorisierter Kontakt", isOn: $isFavourite).onReceive([self.isFavourite].publisher.first()) {value in
                            person.favourite = value
                            saveChange()
                        }
                    }
                }
                Button(action: {
                    showDeleteSheet = true
                }, label: {
                    Label(person.isgroup ? "Gruppe löschen" : "Person löschen", systemImage: "trash").foregroundColor(.red)
                }).actionSheet(isPresented: $showDeleteSheet, content: {
                    self.deletePersonAS
                })
            }
        }
        .animation(.default)
        .navigationBarTitle(person.isgroup ? "Gruppe" : "Person")
        .toolbar(content: {
            ToolbarItem(placement: .automatic) {
                if !isReadOnly {
                    if editMode == EditMode.active {
                        // hier reset button
                    }
                    Button(action: {
                        if editMode == EditMode.inactive {
                            editMode = EditMode.active
                        } else {
                            if person.isgroup {
                                person.groupname = groupName
                            } else {
                                person.vorname = personVorname
                                person.nachname = personNachname
                            }
                            saveChange()
                            editMode = EditMode.inactive
                        }
                    }) {
                        Text(editMode == EditMode.active ? "Fertig" : "Bearbeiten")
                    }
                }
            }
        })
        .environment(\.editMode, $editMode)
    }
}

struct PersonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        //        PersonDetailView(person: PersistentStore.preview.persistentContainer.viewContext, isFavourite: false, isReadOnly: false)//.environment(\.managedObjectContext, PersistentStore.preview.persistentContainer.viewContext)
        PersonDetailView(person: Person(), isFavourite: false, isReadOnly: false)
    }
}
