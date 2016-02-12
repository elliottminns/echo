
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

final class MainQueue {
    
    let identifier: String
    
    var events: [() -> ()]
    
    var eventMutex: pthread_mutex_t
    
    var eventCondition: pthread_cond_t
    
    init(identifier: String) {
        
        self.identifier = identifier
        self.events = []
        self.eventMutex = pthread_mutex_t()
        self.eventCondition = pthread_cond_t()
    }
}

extension MainQueue: DispatchQueue {
    
    func run() {
        
        var conditionMutex = pthread_mutex_t()
        
        pthread_mutex_init(&eventMutex, nil)
        
        pthread_mutex_init(&conditionMutex, nil)
        
        pthread_cond_init (&eventCondition, nil)
        
        pthread_mutex_lock(&conditionMutex)
        
        while true {
            
            pthread_cond_wait(&eventCondition, &conditionMutex)
            
            while events.count > 0 {
                pthread_mutex_lock(&eventMutex)
                let event = events.removeFirst()
                pthread_mutex_unlock(&eventMutex)
                event()
            }
        }
    }
}