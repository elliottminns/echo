#if os(Linux)
import Glibc
let systemSockStream = Int32(SOCK_STREAM.rawValue)
let systemAccept = Glibc.accept
let systemClose = Glibc.close
let systemShutdown = Glibc.shutdown
let systemListen = Glibc.listen
let systemSend = Glibc.send
let systemBind = Glibc.bind
let systemConnect = Glibc.connect
let systemGetHostByName = Glibc.gethostbyname
let systemWrite = Glibc.write
let systemRead = Glibc.read
#else
import Darwin.C
let systemSockStream = SOCK_STREAM
let systemAccept = Darwin.accept
let systemClose = Darwin.close
let systemShutdown = Darwin.shutdown
let systemListen = Darwin.listen
let systemRecv = Darwin.recv
let systemSend = Darwin.send
let systemBind = Darwin.bind
let systemConnect = Darwin.connect
let systemGetHostByName = Darwin.gethostbyname
let systemWrite = Darwin.write
let systemRead = Darwin.read
#endif