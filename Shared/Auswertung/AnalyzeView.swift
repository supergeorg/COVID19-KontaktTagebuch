//
//  AnalyzeView.swift
//  COVID19-KontaktTagebuch
//
//  Created by Georg Meissner on 18.08.20.
//

import SwiftUI
import UniformTypeIdentifiers

struct AnalyzeView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(fetchRequest: PersistentStore.shared.fetchKontakte()) var kontakte: FetchedResults<Kontakt>
    @FetchRequest(fetchRequest: PersistentStore.shared.fetchPersonen()) var personen: FetchedResults<Person>
    
    @State private var exportDocument: ExportDocument = ExportDocument(content: Data())
    
    @State private var infektionsDatum: Date = Calendar.current.startOfDay(for: Date())
    @State var showBetroffene: Bool = false
    @State var isExporting: Bool = false
    
    private func timeSpend() -> Double {
        var time = 0.0
        for kontakt in kontakte {
            time = time + kontakt.duration
        }
        return time
    }
    
    private func getDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter
    }
    
    private func prepareDataModel() -> ExportKT {
        var exportPersonen: ExportPersonen = []
        for person in personen {
            let exP = person.isgroup ? ExportPerson(groupName: person.groupname, nachName: nil, vorName: nil) : ExportPerson(groupName: nil, nachName: person.nachname, vorName: person.vorname)
            exportPersonen.append(exP)
        }
        var exportKontakte: ExportKontakte = []
        for kontakt in kontakte {
            let exK = ExportKontakt(title: kontakt.title!, date: kontakt.date!, duration: kontakt.duration, isOutdoor: kontakt.outdoor, location: kontakt.type)
            exportKontakte.append(exK)
        }
        return ExportKT(title: "Exportierte Daten des COVID-19 Kontakttagebuchs", date: Date(), personen: exportPersonen, kontakte: exportKontakte)
    }
    
    struct ExportDocument: FileDocument {
        static var readableContentTypes: [UTType] { [.json] }
        
        var content: Data
        init(content: Data) {
            self.content = content
        }
        init(configuration: ReadConfiguration) throws {
            guard let data = configuration.file.regularFileContents
            else {
                throw CocoaError(.fileReadCorruptFile)
            }
            content = data
        }
        func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
            return FileWrapper(regularFileWithContents: content)
        }
    }
    
    var body: some View {
        NavigationView() {
            Form{
                Section(header: Text("Statistik")){
                    Label("\(kontakte.count) aufgezeichnete Kontakte", systemImage: "list.number")
                    Label("\(personen.count) gespeicherte Personen", systemImage: "rectangle.stack.person.crop")
                    Label("\(formatDuration(duration2format: timeSpend())) mit Kontakten verbracht", systemImage: "clock")
                }
                Section(header: Text("Kontaktrückverfolgung")){
                    Text("Die Kontaktrückverfolgung hat das Ziel, im Falle einer Infektion alle möglicherweise Infizierten zu finden und zu informieren. Dafür wird der frühest mögliche Zeitpunkt der Infektiösität angegeben und in der darauffolgenden Zeit alle Kontakte aufgelistet.")
                    HStack{
                        Image(systemName: "calendar")
                        DatePicker("Datum", selection: $infektionsDatum, displayedComponents: .date)
                    }
                    Button(action: {
                        self.showBetroffene = true
                    }, label: {
                        Label("Alle Kontakte ab oberen Datum anzeigen", systemImage: "person.2.square.stack")
                            .foregroundColor(.red)
                    }).sheet(isPresented: self.$showBetroffene, content: {KontakteBetroffenView(startDate: infektionsDatum, endDate: Calendar.current.date(byAdding: .weekOfYear, value: 2, to: infektionsDatum)!, isShown: self.$showBetroffene).environment(\.managedObjectContext, self.moc)})
                }
                Section(header: Text("Export")){
                    Text("Für eine anderweitige Nutzung und für Sicherungszwecke kann der Datenbestand in ein maschinenlesbares Format exportiert werden.")
                    Button(action: {
                        let exportData = prepareDataModel()
                        let jsonEncoder = JSONEncoder()
                        jsonEncoder.outputFormatting = .prettyPrinted
                        jsonEncoder.dateEncodingStrategy = .formatted(getDateFormatter())
                        let jsonResultData = try! jsonEncoder.encode(exportData)
                        exportDocument = ExportDocument(content: jsonResultData)
                        isExporting = true
                    }, label: {
                        Label("Export als JSON", systemImage: "square.and.arrow.up")
                    })
                }
            }
            .animation(.default)
            .navigationTitle("Auswertung")
            .fileExporter(
                isPresented: $isExporting,
                document: exportDocument,
                contentType: .json,
                defaultFilename: "KontaktTagebuch-Export"
            ) { result in
                if case .success = result {
                    print("Der Export wurde erfolgreich durchgeführt.")
                } else {
                    print("Der Export wurde wegen eines Fehlers nicht abgeschlossen.")
                }
            }
        }
    }
}

struct AnalyzeView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyzeView()
    }
}
