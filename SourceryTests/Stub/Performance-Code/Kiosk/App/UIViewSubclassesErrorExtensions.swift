import UIKit

extension Button {

    func flashError(_ message: String) {
        let originalTitle = self.title(for: .normal)

        setTitleColor(.white, for: .disabled)
        setBackgroundColor(.artsyRedRegular(), for: .disabled, animated: true)
        setBorderColor(.artsyRedRegular(), for: .disabled, animated: true)

        setTitle(message.uppercased(), for: .disabled)

        delayToMainThread(2) {
            self.setTitleColor(.artsyGrayMedium(), for: .disabled)
            self.setBackgroundColor(.white, for: .disabled, animated: true)
            self.setTitle(originalTitle, for: .disabled)
            self.setBorderColor(.artsyGrayMedium(), for: .disabled, animated: true)
        }
    }
}

extension TextField {

    func flashForError() {
        self.setBorderColor(.artsyRedRegular())
        delayToMainThread(2) {
            self.setBorderColor(.artsyPurpleRegular())
        }
    }
}
