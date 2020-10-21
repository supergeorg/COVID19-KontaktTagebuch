//
//  PersonAddFormView.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 17.08.20.
//

import SwiftUI

struct PersonAddFormView: View {
    @State private var personVorname: String = ""
    @State private var personNachname: String = ""
    @State private var groupName: String = ""
    @State private var isGroup: Bool = false
    @State private var isFavourite: Bool = false
    @Binding var isShown: Bool
    
    private func savePerson() {
        if isGroup{
            PersistentStore.shared.addGroup(groupname: groupName, favourite: isFavourite)
        } else {
            PersistentStore.shared.addPerson(vorname: personVorname, nachname: personNachname, favourite: isFavourite)
        }
    }
    
    var body: some View {
        NavigationView() {
            Form {
                HStack{
                    Image(systemName: isGroup ? "person.3" : "person")
                    Picker("Modus", selection: $isGroup, content: {
                        Text("Einzelperson").tag(false)
                        Text("Gruppe").tag(true)
                    }).pickerStyle(SegmentedPickerStyle())
                }
                if !isGroup{
                    Section(header: Text("Persönliche Daten")){
                        HStack{
                            Image(systemName: "tag")
                            TextField("Vorname", text: $personVorname)
                        }
                        HStack{
                            Image(systemName: "tag")
                            TextField("Nachname", text: $personNachname)
                        }
                    }
                } else {
                    Section(header: Text("Gruppendaten")){
                        HStack{
                            Image(systemName: "tag")
                            TextField("Gruppenname", text: $groupName)
                        }
                    }
                }
                Section(header: Text("Einstellungen")){
                    HStack{
                        Image(systemName: "star")
                        Toggle(isGroup ? "Favorisierte Gruppe" : "Favorisierter Kontakt", isOn: $isFavourite)
                    }
                }
            }
            .animation(.default)
            .navigationBarTitle(isGroup ? "Gruppe hinzufügen" : "Person hinzufügen")
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        self.isShown = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isGroup ? "Gruppe speichern" : "Person speichern") {
                        savePerson()
                        self.isShown = false
                    }.disabled(isGroup ? groupName.isEmpty : (personVorname.isEmpty && personNachname.isEmpty))
                }
            })
        }
    }
}

struct PersonAddFormView_Previews: PreviewProvider {
    static var previews: some View {
        PersonAddFormView(isShown: Binding.constant(true))
    }
}
