//
//  ContentView.swift
//  ConverterFinal
//
//  Created by Peter Gabriel on 18.12.25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var input = 100.0
    //:Dimension ist nötig, damit auch andere UnitWerte (zb UnitMass) zugewiesen werden können.
    @State private var inputWert: Dimension = UnitLength.meters
    @State private var outputWert: Dimension = UnitLength.kilometers
    //Diese var enthält den Index für das conversion Array
    @State private var selectedUnits = 0
    
    @FocusState private var inputIsFocused: Bool
    
    let conversions = ["Distance", "Mass", "Temperature", "Time"]
    //2. Dimensionales Array
    let unitTypes = [
        [UnitLength.feet, UnitLength.kilometers, UnitLength.meters, UnitLength.miles, UnitLength.yards],
        [UnitMass.grams, UnitMass.kilograms, UnitMass.ounces, UnitMass.pounds],
        [UnitTemperature.celsius, UnitTemperature.fahrenheit, UnitTemperature.kelvin],
        [UnitDuration.hours, UnitDuration.minutes, UnitDuration.seconds]
    ]
    
    /*
     Hier bauen wir uns einen custom Formatter. Dies ist nötig, da wir die Units in kompletter länge angezeigt bekommen wollen (M als Meter, KM als Kilometer, usw.).
     Außerdem hat der standard MeasurementFormatter die Eigenschaft, dass er Units overruled, dh wenn man nun KM in Miles umwandeln möchte schaut er zuerst nach welche Einheit lokal verwendet wird und würde in unserem Fall KM in KM umwandeln, da er sich nach der lokalen Einheit richtet. Somit müssen wir ihn mit .providedUnit initialisiern, damit er immer die von uns gewählten Units verwendet. Das ist eine spezieller init() den man so nicht gelernt hat.
     */
    let formatter: MeasurementFormatter
    
    init() {
        formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .long
        
    }
    
    /*In dieser computed property findet die eigentliche Umrechnung statt. Mithilfe von Measurement ist diese nun deutlich kürzer und eleganter, da Apples API die gesamte Arbeit für uns macht.*/
    var result: String {
        let inputMeasurement = Measurement(value: input, unit: inputWert)
        let outputMeasurement = inputMeasurement.converted(to: outputWert)
        return formatter.string(from: outputMeasurement)
    }
    
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                
                Section("Amount to convert") {
                    TextField("Amount", value: $input, format: .number)
                        .keyboardType(.numbersAndPunctuation)
                        .focused($inputIsFocused)
                }
                
                
                Picker("Conversion", selection: $selectedUnits) {
                    ForEach(0..<conversions.count, id: \.self) {
                        Text(conversions[$0])
                    }
                }
                
                
                //Diese Picker verwenden den Wert von selectedUnits um im 2D Array das entsprechende Array zu finden, danach wired es per Loop dargestellt.
                Picker("Convert from", selection: $inputWert) {
                    ForEach(unitTypes[selectedUnits], id: \.self) {
                        Text(formatter.string(from: $0).capitalized)
                    }
                }
                
                
                Picker("Convert to", selection: $outputWert) {
                    ForEach(unitTypes[selectedUnits], id: \.self) {
                        Text(formatter.string(from: $0).capitalized)
                    }
                }
                
                
                Section("Result") {
                    Text(result)
                }
                
                
                
                
            }
            .navigationTitle("Converter")
            .toolbar {
                if inputIsFocused {
                    Button("Done") {
                        inputIsFocused = false
                    }
                }
            }
            
            /*Sobald sich der Wert von selectedUnits änder wird die Closure ausgeführt:
                Zuerst wird das Array aus der 2ten Dimension extrahiert und in "units" gespeichert
                Dann werden dem inputWert und dem outputWert die Stellen 0 und 1 des Array zugewiesen.
                Damit wird sichergestellt dass bei einem Wechsel der Conversion immer auch Convert from und Convert to aktualisiert werden.
             */
            .onChange(of: selectedUnits) {
                let units = unitTypes[selectedUnits]
                inputWert = units[0]
                outputWert = units[1]
            }
            
            
        }
        
        
        
    }
    
    
    
    
}

#Preview {
    ContentView()
}
