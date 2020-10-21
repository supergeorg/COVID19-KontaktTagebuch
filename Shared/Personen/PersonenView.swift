//
//  PersonenView.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 17.08.20.
//

import SwiftUI

struct PersonenView: View {
    let store = PersistentStore.shared
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(fetchRequest: PersistentStore.shared.fetchPersonen()) var personen: FetchedResults<Person>
    
    @State private var showAddPerson = false
    
    var body: some View {
        NavigationView(){
            List{
                if personen.isEmpty {
                    Text("Noch keine Person eingetragen.").padding()
                }
                ForEach(personen, id:\Person.id){person in
                    NavigationLink(destination: PersonDetailView(person: person, isFavourite: person.favourite, isReadOnly: false)) {
                        PersonItemView(person: person, isFavourite: person.favourite)
                    }
                }.animation(.default)
            }
            .animation(.default)
            .navigationBarTitle("Personen")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {showAddPerson = true}, label: {
                            Image(systemName: "person.crop.circle.fill.badge.plus")})
                }
            }
        }
        .sheet(isPresented: self.$showAddPerson, content: {PersonAddFormView(isShown: self.$showAddPerson).environment(\.managedObjectContext, self.moc)})
    }
}

struct PersonenView_Previews: PreviewProvider {
    static var previews: some View {
        PersonenView().environment(\.managedObjectContext, PersistentStore.preview.persistentContainer.viewContext)
    }
}
