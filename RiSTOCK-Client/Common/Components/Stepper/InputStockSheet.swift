//
//  StepperSheetView.swift
//  RiSTOCK-Client
//
//  Created by Teuku Fazariz Basya on 23/11/25.
//

import SwiftUI

struct StockUpdateView: View {
    //MARK: Button Edit Stock
    @State private var showInputSheet = false
    @State private var currentStock = 0
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            Button(action: {
                showInputSheet.toggle()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                }
                .padding()
                .cornerRadius(8)
            }
        }
        // MARK: - The Sheet Logic
        .sheet(isPresented: $showInputSheet) {
            InputStockSheet(
                isPresented: $showInputSheet,
                initialStock: currentStock,
                productName: "1lusin cetakan kue putu",
                onSave: { newQuantity in
                    // Inject data disini
                    self.currentStock = newQuantity
                    print("Stock updated to: \(newQuantity)")
                }
            )
            //Atur tinggi sheet
            .presentationDetents([.height(400)])
            .presentationCornerRadius(24)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Reusable Sheet Component
struct InputStockSheet: View {
    @Binding var isPresented: Bool
    let initialStock: Int
    let productName: String
    var onSave: (Int) -> Void
    
    @State private var quantity: Int
    @State private var quantityString: String
    @State private var isLongPressingMinus = false
    @State private var isLongPressingPlus = false
    @State private var longPressTimer: Timer?
    
    init(isPresented: Binding<Bool>, initialStock: Int, productName: String, onSave: @escaping (Int) -> Void) {
        self._isPresented = isPresented
        self.initialStock = initialStock
        self.productName = productName
        self.onSave = onSave
        self._quantity = State(initialValue: initialStock)
        self._quantityString = State(initialValue: String(initialStock))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            VStack(spacing: 8) {
                Rectangle()
                    .frame(width: 50, height: 5)
                    .background(Color(.systemGray5))
                    .cornerRadius(2.5)
                    .padding(.top, 30)
                
                Text("Input Stok")
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.top, 20)
                
                Text(productName)
                    .font(.system(size: 15))
                    .foregroundColor(Token.gray1000.swiftUIColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }
            
            HStack(spacing: 20) {
                Button(action: {}) {
                    Image(systemName: "minus")
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 50, height: 50)
                        .foregroundColor(quantityString != "0" ? Token.primary600.swiftUIColor : Token.gray500.swiftUIColor)
                        .background(quantityString != "0" ? Token.primary50.swiftUIColor : Token.gray50.swiftUIColor)
                        .clipShape(Circle())
                        .scaleEffect(isLongPressingMinus ? 0.95 : 1.0)
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isLongPressingMinus {
                                isLongPressingMinus = true
                                startDecrementTimer()
                            }
                        }
                        .onEnded { _ in
                            stopTimer()
                            isLongPressingMinus = false
                        }
                )
                
                // Text Field Input
                TextField("0", text: $quantityString)
                    .font(.system(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .frame(width: 136, height: 64)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Token.gray500.swiftUIColor, lineWidth: 1)
                    )
                    .onChange(of: quantityString) { newValue in
                        handleTextChange(newValue)
                    }
                
                // Increment Button
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .background(Token.primary500.swiftUIColor)
                        .clipShape(Circle())
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isLongPressingPlus {
                                isLongPressingPlus = true
                                startIncrementTimer()
                            }
                        }
                        .onEnded { _ in
                            stopTimer()
                            isLongPressingPlus = false
                        }
                )
            }
            .padding(.vertical, 10)
            
            // 3. Info & Preview (Minimum Stock & arrow transition)
            VStack(spacing: 8) {
                Text("Minimum Stok: 100")
                    .foregroundColor(.primary)
                    .font(.system(size: 16))
                    .padding(.bottom, 15)
                
                HStack {
                    Text("\(initialStock)")
                        .foregroundColor(.gray)
                        .font(.system(size: 25))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 25))
                        .foregroundColor(.gray)
                    Text("\(quantity)")
                        .fontWeight(.bold)
                        .font(.system(size: 25))
                }
                .padding(.bottom, 15)
            }
            
            // 4. Action Buttons (Cancel / Save)
            HStack(spacing: 16) {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Token.primary50.swiftUIColor)
                        .foregroundColor(Token.primary600.swiftUIColor)
                        .cornerRadius(30)
                }
                
                Button(action: {
                    onSave(quantity)
                    isPresented = false
                }) {
                    Text("Simpan")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Token.primary600.swiftUIColor)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    func increment(by amount: Int = 1) {
        quantity += amount
        quantityString = String(quantity)
    }
    
    func decrement(by amount: Int = 1) {
        quantity = max(0, quantity - amount)
        quantityString = String(quantity)
    }
    
    func startIncrementTimer() {
        increment(by: 1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard self.isLongPressingPlus else { return }
            
            self.longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                self.increment(by: 10)
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    }
    
    func startDecrementTimer() {
        decrement(by: 1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard self.isLongPressingMinus else { return }
            
            self.longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                self.decrement(by: 10)
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    }
    
    func stopTimer() {
        longPressTimer?.invalidate()
        longPressTimer = nil
    }
    
    func handleTextChange(_ newValue: String) {
        let filtered = newValue.filter { $0.isNumber }
        
        if filtered != newValue {
            quantityString = filtered
        }
        
        if let value = Int(filtered) {
            quantity = value
        } else {
            if filtered.isEmpty {
                quantity = 0
            }
        }
    }
}

// MARK: - Preview
struct StockUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        StockUpdateView()
    }
}

