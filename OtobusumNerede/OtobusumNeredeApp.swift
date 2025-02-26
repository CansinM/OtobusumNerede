import SwiftUI
import SwiftData

@main
struct OtobusumNeredeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            City.self, // Şehir modelini ekledik
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .onAppear {
                    addDefaultCitiesIfNeeded()
                }
        }
    }

    // Varsayılan şehirleri ekleme fonksiyonu
    @MainActor func addDefaultCitiesIfNeeded() {
        let context = sharedModelContainer.mainContext
        let fetchDescriptor = FetchDescriptor<City>()
        
        do {
            // Check if any cities are already stored
            if try context.fetch(fetchDescriptor).isEmpty {
                // If empty, add default cities
                addDefaultCities(to: context)
            }
        } catch {
            print("Error fetching cities: \(error)")
        }
    }
    
    // Varsayılan şehirleri ekleme fonksiyonu
    func addDefaultCities(to context: ModelContext) {
        let cities = [
            City(name: "İstanbul", latitude: 41.04124295119551, longitude: 28.892961713110324),
            City(name: "Ankara", latitude: 39.91922282467059, longitude: 32.8124133672408),
            City(name: "İzmir", latitude: 38.43235381105256, longitude: 27.213664125186995),
            City(name: "Antalya", latitude: 36.92191963957377, longitude: 30.66493170977289),
            City(name: "Bursa", latitude: 40.26587425839043, longitude: 29.05533494061983),
            City(name: "Adana", latitude: 36.997157966017475, longitude: 35.264156709776465),
            City(name: "Samsun", latitude: 41.28736240653642, longitude: 36.28946739649466),
            City(name: "Erzurum", latitude: 39.96160580962217, longitude: 41.22031049457884)
        ]
        
        cities.forEach { context.insert($0) }
        try? context.save()
    }
}

