
import SwiftUI

struct RootView: View {
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true

    var body: some View {
        if isFirstLaunch {
            WelcomeView()
        } else {
            ContentView()
        }
    }
}
