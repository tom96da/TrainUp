import SwiftUI

struct WelcomeView: View {
    @AppStorage("username") private var username: String = ""
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @State private var tempUsername: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                TextField("Enter your username", text: $tempUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    let trimmed = tempUsername.trimmingCharacters(in: .whitespaces)
                    if (!trimmed.isEmpty) {
                        username = trimmed
                        isFirstLaunch = false
                    }
                }) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(trimmedIsEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .disabled(tempUsername.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .navigationBarHidden(true)
            .onAppear {
                if !username.isEmpty {
                    tempUsername = username
                }
            }
        }
    }

    private var trimmedIsEmpty: Bool {
        tempUsername.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
