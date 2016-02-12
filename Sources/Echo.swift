// import Foundation

public class Echo {

    static let instance = Echo()

    private var running = false

    let mainQueue: MainQueue
    let globalQueue: ConcurrentQueue

    private init() {
        mainQueue = MainQueue(identifier:"com.queue.main")
        globalQueue = ConcurrentQueue(identifier: "com.queue.global")
    }

    func begin() {
        if !running {
            mainQueue.run()
        }
    }

    public class func beginEventLoop() {
        Echo.instance.begin()
    }
}
