//
//  PersistentStore.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 17.08.20.
//

import Foundation
import CoreData

final class PersistentStore: ObservableObject {
    static let shared = PersistentStore()
    
    func fetchKontakte() -> NSFetchRequest<Kontakt> {
        let request: NSFetchRequest<Kontakt> = Kontakt.fetchRequest()
        let sortDate = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDate]
        return request
    }
    
    func fetchKontakteBetweenDates(startDate: Date, endDate: Date) -> NSFetchRequest<Kontakt> {
        let request: NSFetchRequest<Kontakt> = Kontakt.fetchRequest()
        let sortDate = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDate]
        request.predicate = NSPredicate(format: "date >= %@ && date <= %@", startDate as NSDate, endDate as NSDate)
        return request
    }
    
    func fetchPersonen() -> NSFetchRequest<Person> {
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        let sortFavourite = NSSortDescriptor(key: "favourite", ascending: false)
        let sortGroup = NSSortDescriptor(key: "isgroup", ascending: false)
        let sortGroupName = NSSortDescriptor(key: "groupname", ascending: true)
        let sortNachName = NSSortDescriptor(key: "nachname", ascending: true)
        let sortVorName = NSSortDescriptor(key: "vorname", ascending: true)
        request.sortDescriptors = [sortFavourite, sortGroup, sortGroupName, sortNachName, sortVorName]
        return request
    }
    
    func addPerson(vorname: String, nachname: String, favourite: Bool) {
        let entityName = "Person"
        let moc = persistentContainer.viewContext
        
        guard let personEntity = NSEntityDescription.entity(forEntityName: entityName, in: moc) else {return}
        
        let newPerson = NSManagedObject(entity: personEntity, insertInto: moc)
        
        let id = UUID()
        newPerson.setValue(id, forKey: "id")
        newPerson.setValue(vorname, forKey: "vorname")
        newPerson.setValue(nachname, forKey: "nachname")
        newPerson.setValue(favourite, forKey: "favourite")
        newPerson.setValue(false, forKey: "isgroup")
        
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    func addGroup(groupname: String, favourite: Bool) {
        let entityName = "Person"
        let moc = persistentContainer.viewContext
        
        guard let personEntity = NSEntityDescription.entity(forEntityName: entityName, in: moc) else {return}
        
        let newGroup = NSManagedObject(entity: personEntity, insertInto: moc)
        
        let id = UUID()
        newGroup.setValue(id, forKey: "id")
        newGroup.setValue(groupname, forKey: "groupname")
        newGroup.setValue(favourite, forKey: "favourite")
        newGroup.setValue(true, forKey: "isgroup")
        
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    func addKontakt(title: String, date: Date, isOutdoor: Bool, duration: Double, kontaktPersonen: Set<Person>) {
        let entityName = "Kontakt"
        let moc = persistentContainer.viewContext
        
        guard let kontaktEntity = NSEntityDescription.entity(forEntityName: entityName, in: moc) else {return}
        
        let newKontakt = NSManagedObject(entity: kontaktEntity, insertInto: moc)
        
        let id = UUID()
        newKontakt.setValue(id, forKey: "id")
        newKontakt.setValue(title, forKey: "title")
        newKontakt.setValue(date, forKey: "date")
        newKontakt.setValue(duration, forKey: "duration")
        newKontakt.setValue(isOutdoor, forKey: "outdoor")
        
        let personen = newKontakt.mutableSetValue(forKey: "personen")
        for person in kontaktPersonen{
            personen.add(person)
        }
        
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    func deletePerson(person: Person) {
        let moc = persistentContainer.viewContext
        moc.delete(person)
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    func deleteKontakt(kontakt: Kontakt) {
        let moc = persistentContainer.viewContext
        moc.delete(kontakt)
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "KontaktModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
