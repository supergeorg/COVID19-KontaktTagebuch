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
    var person: Person
    @State var isfavourite: Bool
    @State private var showDeleteSheet: Bool = false
    var isReadOnly: Bool
    
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
        NavigationView{
            Form {
                if person.isgroup{
                    Section(header: Text("Gruppendaten")){
                        Label(person.groupname ?? "kein Gruppenname", systemImage: "person.3")
                    }
                } else {
                    Section(header: Text("Persönliche Daten")){
                        Label("\(person.vorname ?? "kein Vorname") \(person.nachname ?? "kein Nachname")", systemImage: "person")
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
                        Toggle(person.isgroup ? "Favorisierte Gruppe" : "Favorisierter Kontakt", isOn: $isfavourite).onReceive([self.isfavourite].publisher.first()) {value in
                            person.favourite = value
                            saveChange()
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
        }
        .navigationBarTitle(person.isgroup ? "Gruppe" : "Person")
    }
}

struct PersonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailView(person: Person(), isfavourite: false, isReadOnly: false)
    }
}
