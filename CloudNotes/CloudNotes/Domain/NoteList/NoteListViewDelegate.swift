import Foundation

protocol NoteListViewDelegate: AnyObject {
    func passNote(at index: Int)

    func creatNote()

    func deleteNote(_ note: Content, index: Int)
}
