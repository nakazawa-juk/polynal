import AVFoundation
import SwiftUI

class SpeechSynthesizerDelegate: NSObject, AVSpeechSynthesizerDelegate {
  var onFinish: (() -> Void)?
  var onCancel: (() -> Void)?

  func speechSynthesizer(_: AVSpeechSynthesizer, didFinish _: AVSpeechUtterance) {
    onFinish?()
  }

  func speechSynthesizer(_: AVSpeechSynthesizer, didCancel _: AVSpeechUtterance) {
    onCancel?()
  }
}

struct DiaryDetailView: View {
  @Binding var diary: Diary
  @State private var isEditing = false
  @State private var editedContent: String = ""
  @State private var translatedContent: String = ""
  @State private var isReadingAloud = false
  private let synthesizer = AVSpeechSynthesizer()
  private let speechDelegate = SpeechSynthesizerDelegate()

  var body: some View {
    VStack {
      if isEditing {
        TextEditor(text: $editedContent)
          .padding()
        Button(action: saveDiary) {
          Text("保存")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
      } else {
        Text(diary.content)
          .padding()
        if !diary.translatedContent.isEmpty {
          ScrollView {
            MarkdownTextView(text: diary.translatedContent)
              .padding()
              .background(Color(UIColor.systemGray6))
              .cornerRadius(8)
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(Color.gray, lineWidth: 1)
              )
          }
          .padding()
          .scrollIndicators(.visible)
        }
        Spacer()
        HStack {
          Button(action: translateDiary) {
            Text("英訳")
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.green)
              .foregroundColor(.white)
              .cornerRadius(8)
          }
          .padding(.horizontal)
          .padding(.bottom, 1)
          Button(action: toggleReadAloud) {
            Text(isReadingAloud ? "停止" : "読み上げ")
              .frame(maxWidth: .infinity)
              .padding()
              .background(isReadingAloud ? Color.red : Color.orange)
              .foregroundColor(.white)
              .cornerRadius(8)
          }
          .padding(.horizontal)
          .padding(.bottom, 1)
        }
        Button(action: toEdit) {
          Text("編集")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(.horizontal)
        .padding(.top, 1)
      }
    }
    .navigationTitle(diary.formattedDate)
    .onAppear {
      editedContent = diary.content
      synthesizer.delegate = speechDelegate
      speechDelegate.onFinish = {
        isReadingAloud = false
      }
      speechDelegate.onCancel = {
        isReadingAloud = false
      }
    }
  }

  private func saveDiary() {
    diary.content = editedContent
    if let index = Diary.loadDiaries().firstIndex(where: { $0.id == diary.id }) {
      var diaries = Diary.loadDiaries()
      diaries[index] = diary
      Diary.saveDiaries(diaries)
    }
    isEditing = false
  }

  private func translateDiary() {
    stopSpeaking()
    // EnvLoaderを使用して環境変数からAPIキーを取得
    guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
      print("API key not found")
      return
    }

    // ChatGPT APIを使用して英訳を取得する処理を実装
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let prompt = "英語を学習中。日記を英訳して、各フレーズを解説してください。解説は短く。使用する英単語の意味も教えて。\n【フォーマット】\n## Translated\n---\n## explain \(diary.content)"

    let body: [String: Any] = [
      // "model": "gpt-3.5-turbo-0125",
      "model": "chatgpt-4o-latest",
      "messages": [
        ["role": "user", "content": prompt],
      ],
    ]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

    URLSession.shared.dataTask(with: request) { data, _, error in
      guard let data = data, error == nil else {
        print("Error: \(error?.localizedDescription ?? "Unknown error")")
        return
      }
      print("data: \(data)")
      if let response = try? JSONDecoder().decode(ChatGPTResponse.self, from: data) {
        print("Response: \(response)")
        if let translatedText = response.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) {
          DispatchQueue.main.async {
            translatedContent = translatedText
            print("Translated content: \(translatedContent)")

            // translatedContentを日記データに追加して保存
            diary.translatedContent = translatedContent
            if let index = Diary.loadDiaries().firstIndex(where: { $0.id == diary.id }) {
              var diaries = Diary.loadDiaries()
              diaries[index] = diary
              Diary.saveDiaries(diaries)
            }
          }
        } else {
          print("No translated text found in response.")
        }
      } else {
        let responseString = String(data: data, encoding: .utf8) ?? ""
        print("Response string: \(responseString)")
      }
    }.resume()
  }

  private func toggleReadAloud() {
    if isReadingAloud {
      stopSpeaking()
    } else {
      readAloud()
    }
  }

  private func stopSpeaking() {
    synthesizer.stopSpeaking(at: .immediate)
    isReadingAloud = false
  }

  private func readAloud() {
    let pattern = "## Translated\\s*(.*?)\\s*---"
    if let range = diary.translatedContent.range(of: pattern, options: .regularExpression) {
      let contentToRead = String(diary.translatedContent[range])
        .replacingOccurrences(of: "## Translated", with: "")
        .replacingOccurrences(of: "---", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
      print("読み上げる内容: \(contentToRead)")
      let utterance = AVSpeechUtterance(string: contentToRead)

      utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
      utterance.rate = 0.3

      synthesizer.speak(utterance)
      isReadingAloud = true
    } else {
      print("指定されたパターンが見つかりませんでした。")
    }
  }

  private func toEdit() {
    stopSpeaking()
    isEditing = true
  }
}

struct ChatGPTResponse: Codable {
  struct Choice: Codable {
    struct Message: Codable {
      let content: String
    }

    let message: Message
  }

  let choices: [Choice]
}
