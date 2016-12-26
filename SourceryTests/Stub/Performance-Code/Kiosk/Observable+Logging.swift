import RxSwift

extension Observable {
    func logError(prefix: String = "Error: ") -> Observable<Element> {
        return self.do(onError: { error in
            print("\(prefix)\(error)")
        })
    }

    func logServerError(message: String) -> Observable<Element> {
        return self.do(onError: { e in
            let error = e as NSError
            logger.log(message)
            logger.log("Error: \(error.localizedDescription). \n \(error.artsyServerError())")
        })
    }

    func logNext() -> Observable<Element> {
        return self.do(onNext: { element in
            print("\(element)")
        })
    }
}
