import SwiftUI
import MapKit

// Örnek otobüs modelini tanımlayalım
struct Bus: Identifiable {
    let id = UUID()
    let name: String
    let departureTime: String
    let arrivalTime: String
    let duration: String
}

struct BusListScreen: View {
    var fromCity: String
    var toCity: String
    var travelDate: Date
    
    let buses = [
        Bus(name: "Metro Turizm", departureTime: "12:00", arrivalTime: "16:00", duration: "4 saat"),
        Bus(name: "Pamukkale", departureTime: "13:30", arrivalTime: "18:00", duration: "4.5 saat"),
        Bus(name: "Kamil Koç", departureTime: "14:00", arrivalTime: "19:00", duration: "5 saat"),
        Bus(name: "Lüks Artvin", departureTime: "22:00", arrivalTime: "09:00", duration: "11 saat")
    ]
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("\(fromCity) → \(toCity)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .foregroundColor(.blue)
                
                List(buses) { bus in
                    NavigationLink(destination: BusDetailView(bus: bus, fromCity: fromCity, toCity: toCity)) {
                        BusRow(bus: bus)
                    }
                    .padding(.vertical, 10)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Otobüs Seçimi")
    }
}

struct BusRow: View {
    var bus: Bus
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(bus.name)
                    .font(.headline)
                    .foregroundColor(.blue)
                Text("Kalkış: \(bus.departureTime) - Varış: \(bus.arrivalTime)")
                Text("Süre: \(bus.duration)")
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "bus.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

