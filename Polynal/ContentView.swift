import SwiftUI

struct ContentView: View {
  @State private var diaries: [Diary] = Diary.loadDiaries()
  @State private var showingAddDiaryView = false

  var body: some View {
    NavigationView {
      List {
        ForEach($diaries) { $diary in
          NavigationLink(destination: DiaryDetailView(diary: $diary)) {
            VStack(alignment: .leading) {
              Text(diary.formattedDate)
                .font(.headline)
              Text(diary.content)
                .lineLimit(1)
            }
          }
        }
        .onDelete(perform: deleteDiary)
      }
      .navigationTitle("Polynal")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            showingAddDiaryView = true
          }) {
            Image(systemName: "plus")
          }
        }
      }
      .sheet(isPresented: $showingAddDiaryView) {
        AddDiaryView(diaries: $diaries)
      }
    }
  }

  private func deleteDiary(at offsets: IndexSet) {
    diaries.remove(atOffsets: offsets)
    Diary.saveDiaries(diaries)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
