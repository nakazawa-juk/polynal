import Foundation

enum EnvLoader {
  static func loadEnv() {
    guard let path = Bundle.main.path(forResource: ".env", ofType: nil) else {
      print(".env file not found")
      return
    }
    do {
      let data = try String(contentsOfFile: path, encoding: .utf8)
      let lines = data.split { $0.isNewline }
      for line in lines {
        let parts = line.split(separator: "=", maxSplits: 1).map { String($0) }
        if parts.count == 2 {
          setenv(parts[0], parts[1], 1)
        }
      }
    } catch {
      print("Error loading .env file: \(error)")
    }
  }
}
