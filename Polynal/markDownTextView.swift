import SwiftUI

struct MarkdownTextView: View {
  var text: String

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(text.split(separator: "\n"), id: \.self) { line in
        if line.starts(with: "## ") {
          Text(line.replacingOccurrences(of: "## ", with: ""))
            .font(.title2)
            .fontWeight(.bold)
        } else if line.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
          Text(line
            .replacingOccurrences(of: #"(\d+\.\s)"#, with: "\n$1", options: .regularExpression)
            .replacingOccurrences(of: "**", with: "")
          )
          .fontWeight(.bold)
        } else if line.contains("**") {
          Text(line.replacingOccurrences(of: "**", with: ""))
        } else if line.contains("---") {
          Text(line.replacingOccurrences(of: "---", with: ""))
        } else {
          Text(line)
        }
      }
    }
    .padding()
  }
}
