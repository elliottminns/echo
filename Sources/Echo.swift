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

    func exit() {
        if running {
            #if os(Linux)
            mainQueue.exit()
            #else
            let loop = NSRunLoop.mainRunLoop().getCFRunLoop()
            CFRunLoopStop(loop)
            #endif
        }
    }

    public class func begin() {
        Echo.instance.begin()
    }

    public class func beginEventLoop() {
        Echo.instance.begin()
    }

    public class func exit() {
        Echo.instance.exit()
    }
}
