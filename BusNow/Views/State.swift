//
//  State.swift
//  BusNow
//
//  Created by matsumotoryota on 2025/03/22.
//

import Foundation
import SwiftUI

struct StateView : View {
    @State private var isPressed = false
    var body: some View {
        VStack{
            HeaderView(isPressed: $isPressed)

        }
        
    }
}

struct HeaderView : View {
    @Binding var isPressed : Bool
    var body: some View {
        Text("Tap")
            .padding()
            .background(isPressed ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .gesture{
                DragGesture(minimumDistance: 0 )
                    .onChanged { _ in
                        isPressed.toggle()
                    }
            }
    }
}

struct ButtonView : View {q
    @Binding var color : Color
    
    var body : some View {
        Button ("Change Color"){
            color = color == Color.blue ? Color.red : Color.blue
        }
        
    }
}


#Preview {
    StateView()
}
