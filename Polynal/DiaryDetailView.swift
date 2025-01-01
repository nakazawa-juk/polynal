import SwiftUI

struct DiaryDetailView: View {
  @Binding var diary: Diary
  @State private var isEditing = false
  @State private var editedContent: String = ""

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
        Button(action: { isEditing = true }) {
          Text("編集")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
      }
    }
    .navigationTitle(diary.formattedDate)
    .onAppear {
      editedContent = diary.content
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
}
