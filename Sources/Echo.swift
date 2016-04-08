import Foundation
import CUV

public class EchoLoop {

    static let instance = EchoLoop()

    private var running = false
    
    var loop: UnsafeMutablePointer<uv_loop_t>

    private init() {
        loop = uv_default_loop()
    }

    func begin() {
        uv_run(loop, UV_RUN_DEFAULT)
    }

    func exit() {
    }

    public class func begin() {
        EchoLoop.instance.begin()
    }

    public class func beginEventLoop() {
        EchoLoop.instance.begin()
    }

    public class func exit() {
        EchoLoop.instance.exit()
    }
}
