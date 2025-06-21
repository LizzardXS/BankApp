import Foundation

struct BankAccount: Codable {
    let name: String
    let balance: Double
}

struct UserData: Codable {
    let login: String
    let email: String
    let password: String
    var bankAccounts: [BankAccount]

    private static let filename = "User.plist"

    static func loadAllUsers() -> [UserData] {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename) else {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let users = try PropertyListDecoder().decode([UserData].self, from: data)
            return users
        } catch {
            print("Ошибка загрузки пользователей: \(error)")
            return []
        }
    }

    static func saveAllUsers(_ users: [UserData]) {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename) else {
            return
        }
        do {
            let data = try PropertyListEncoder().encode(users)
            try data.write(to: url)
        } catch {
            print("Ошибка сохранения пользователей: \(error)")
        }
    }

    static func findUser(loginOrEmail: String, password: String) -> UserData? {
        let users = loadAllUsers()
        return users.first { ($0.login == loginOrEmail || $0.email == loginOrEmail) && $0.password == password }
    }

    static func addUser(_ newUser: UserData) -> Bool {
        var users = loadAllUsers()
        if users.contains(where: { $0.login == newUser.login || $0.email == newUser.email }) {
            return false
        }
        users.append(newUser)
        saveAllUsers(users)
        return true
    }

    static func loadCurrentUser() -> UserData? {
        guard let currentLogin = UserDefaults.standard.string(forKey: "currentUserLogin") else { return nil }
        let users = loadAllUsers()
        return users.first(where: { $0.login == currentLogin })
    }

    static func updateUser(_ updatedUser: UserData) {
        var users = loadAllUsers()
        if let index = users.firstIndex(where: { $0.login == updatedUser.login }) {
            users[index] = updatedUser
            saveAllUsers(users)
        }
    }
}
