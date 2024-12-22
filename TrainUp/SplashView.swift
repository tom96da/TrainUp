
import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        VStack {
            Text("TrainUp")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(2)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            RootView()
        }
    }
}
