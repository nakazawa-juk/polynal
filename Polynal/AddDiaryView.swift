import SwiftUI

struct AddDiaryView: View {
  @Environment(\.presentationMode) var presentationMode
  @State private var content: String = ""
  @Binding var diaries: [Diary]

  var body: some View {
    NavigationView {
      VStack {
        TextEditor(text: $content)
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
      }
      .navigationTitle("新規日記")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("キャンセル") {
            presentationMode.wrappedValue.dismiss()
          }
        }
      }
    }
  }

  private func saveDiary() {
    let newDiary = Diary(id: UUID(), date: Date(), content: content)
    diaries.append(newDiary)
    Diary.saveDiaries(diaries)
    presentationMode.wrappedValue.dismiss()
  }
}
