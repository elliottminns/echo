import Foundation

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
            #if os(Linux)
            mainQueue.run()
            #else
            NSRunLoop.mainRunLoop().run()
            #endif
        }
    }

    public class func beginEventLoop() {
        Echo.instance.begin()
    }
}
