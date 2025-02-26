import SwiftUI

struct ContentView: View {
    let cities = ["İstanbul", "Ankara", "İzmir", "Antalya", "Bursa", "Adana", "Samsun", "Erzurum"]
    
    @State private var selectedFromCity = "İstanbul"
    @State private var selectedToCity = "Ankara"
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.red, Color.white]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Otobüsüm Nerede?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    VStack(spacing: 20) {
                        // Nereden seçimi
                        PickerSelectionView(title: "Nereden", selection: $selectedFromCity, options: cities)
                        
                        // Nereye seçimi
                        PickerSelectionView(title: "Nereye", selection: $selectedToCity, options: cities)
                        
                        // Sefer tarihi seçimi
                        DatePicker("Sefer Tarihi", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding()
                    }
                    .padding(.horizontal, 20)
                    
                    // Otobüs ara butonu
                    NavigationLink(destination: BusListScreen(fromCity: selectedFromCity, toCity: selectedToCity, travelDate: selectedDate)) {
                        Text("Otobüs Ara")
                            .bold()
                            .frame(width: 200, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    .padding(.top, 30)

                    Spacer()
                }
            }
        }
    }
}

struct PickerSelectionView: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

