//
//  ContentView.swift
//  BetterRestApp
//
//  Created by Kellie Ho on 2025-06-09.
//

//Model takes in three inputs: desired wake time in seconds, estimated sleep in hours, and coffee intake in cups. It outputs the ideal bedtime in seconds.

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = wakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var bedtimeMessage = ""
    
    //alert variables
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    static var wakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading) {
                    Text("When do you want to wake up?")
                    DatePicker("What time do you want to wake up?: ", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden() }

                VStack(alignment: .leading) {
                    Text("Desired amount of sleep: ")
                    Stepper("\(sleepAmount.formatted()) Hours", value: $sleepAmount, in: 4...12, step: 0.5) }

                VStack(alignment: .leading) {
                    Text("Daily coffee intake: ")
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 0...20) } //allows for pluralization of "cup" based on the amount of coffee

                VStack(alignment: .center) {
                    Text(alertTitle)
                        .font(.headline)
                        
                    Text(alertMessage)
                }
                .padding()
                
                
                
            }
            

    
            .navigationTitle("Ideal Bedtime AI ⏰")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: wakeUp) {
                calculateBedtime() // Recalculate bedtime whenever the wakeUp time changes
            }
            .onChange(of: coffeeAmount) {
                calculateBedtime() // Recalculate bedtime whenever the wakeUp time changes
            }
            .onChange(of: sleepAmount) {
                calculateBedtime() // Recalculate bedtime whenever the wakeUp time changes
            }
            
            
            
        }
    }
    
    func calculateBedtime() { //Need to use do/try/catch to handle errors: when loading the model and asking for predictions.
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            // Get the components of the wakeUp date in seconds
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp) // Extract hour and minute specifically from the wakeUp date
            let hour = (components.hour ?? 0) * 60 * 60 // Use nil coalescing to provide a default value, covert hour to seconds by multiplying by 60 twice
            let minute = (components.minute ?? 0) * 60 // Convert minutes to seconds
            
            //feed the model with the input data (requires Double values of hour and minute, sleep amount, and coffee amount)
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep // Calculate the ideal bedtime by subtracting the predicted sleep duration from the wakeUp time
            let sleepHours = prediction.actualSleep / 3600 // Convert seconds to hours
            
            alertTitle = "Your Ideal Bedtime"
            alertMessage = "Your ideal bedtime is \(sleepTime.formatted(date: .omitted, time: .shortened)). You will get \(hoursAndMins(sleepHours)) hours of sleep."
            
            func hoursAndMins(_ input: Double) -> String {
                let hours = Int(input)
                let minutes = input - Double(hours)
                return "\(hours) hours and \(Int(minutes * 60)) minutes"
                
            }
            
//            bedtimeMessage = "Your ideal bedtime is \(sleepTime.formatted(date: .omitted, time: .shortened)). You will get \(sleepHours.rounded(.down)) hours of sleep." //change to hours with decimal
        
        } catch {
            alertTitle = "Error"
            alertMessage = "There was a problem calculating your bedtime. Please try again."
            
        }
        
        showAlert = true
    }
    
}

#Preview {
    ContentView()
}
