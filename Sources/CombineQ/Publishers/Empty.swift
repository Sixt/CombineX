extension Publishers {
    
    /// A publisher that never publishes any values, and optionally finishes immediately.
    ///
    /// You can create a ”Never” publisher — one which never sends values and never finishes or fails — with the initializer `Empty(completeImmediately: false)`.
    public struct Empty<Output, Failure> : Publisher, Equatable where Failure : Error {
        
        /// Creates an empty publisher.
        ///
        /// - Parameter completeImmediately: A Boolean value that indicates whether the publisher should immediately finish.
        public init(completeImmediately: Bool = true) {
            self.completeImmediately = completeImmediately
        }
        
        /// Creates an empty publisher with the given completion behavior and output and failure types.
        ///
        /// Use this initializer to connect the empty publisher to subscribers or other publishers that have specific output and failure types.
        /// - Parameters:
        ///   - completeImmediately: A Boolean value that indicates whether the publisher should immediately finish.
        ///   - outputType: The output type exposed by this publisher.
        ///   - failureType: The failure type exposed by this publisher.
        public init(completeImmediately: Bool = true, outputType: Output.Type, failureType: Failure.Type) {
            Global.RequiresImplementation()
        }
        
        /// A Boolean value that indicates whether the publisher immediately sends a completion.
        ///
        /// If `true`, the publisher finishes immediately after sending a subscription to the subscriber. If `false`, it never completes.
        public let completeImmediately: Bool
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
            
        }
        
        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (lhs: Publishers.Empty<Output, Failure>, rhs: Publishers.Empty<Output, Failure>) -> Bool {
            Global.RequiresImplementation()
        }
    }
}

extension Publishers.Empty {
    
    private final class EmptySubscriptions<S>:
        CustomSubscription<Publishers.Empty<Output, Failure>, S>
    where
        S : Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        
        let state = Atomic<State>(value: .waiting)
        
        override func request(_ demand: Subscribers.Demand) {
            if self.state.compareAndStore(expected: .waiting, newVaue: .subscribing(demand)) {
                
                guard demand > 0 else {
                    // REMINDME: Combine crashes here.
                    fatalError("trying to request '<= 0' values from Empty")
                }
                
                if self.pub.completeImmediately {
                    self.sub.receive(completion: .finished)
                }
                
                self.state.store(.finished)
            }
        }
        
        override func cancel() {
            self.state.store(.finished)
        }
    }
}


