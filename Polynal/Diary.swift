import Foundation

struct Diary: Identifiable, Codable {
  let id: UUID
  let date: Date
  var content: String
  var translatedContent: String

  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM.dd HH:mm"
    formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
    return formatter.string(from: date)
  }

  static func loadDiaries() -> [Diary] {
    guard let data = UserDefaults.standard.data(forKey: "diaries"),
          let diaries = try? JSONDecoder().decode([Diary].self, from: data)
    else {
      return []
    }
    return diaries
  }

  static func saveDiaries(_ diaries: [Diary]) {
    guard let data = try? JSONEncoder().encode(diaries) else { return }
    UserDefaults.standard.set(data, forKey: "diaries")
  }
}
