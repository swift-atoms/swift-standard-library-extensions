extension Swift.Result where Success: Copyable {
    
    @inlinable
    public func get() throws(Failure) -> Success {
        switch self {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }
    
    @inlinable
    public func map<NewSuccess>(
        _ transform: (Success) -> NewSuccess
    ) -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value): .success(transform(value))
        case .failure(let error): .failure(error)
        }
    }
    
    @inlinable
    public func flatMap<NewSuccess>(
        _ transform: (Success) -> Result<NewSuccess, Failure>
    ) -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value): transform(value)
        case .failure(let error): .failure(error)
        }
    }
    
    @inlinable
    public func mapError<NewFailure: Swift.Error>(
        _ transform: (Failure) -> NewFailure
    ) -> Result<Success, NewFailure> {
        switch self {
        case .success(let value): .success(value)
        case .failure(let error): .failure(transform(error))
        }
    }
    
    @inlinable
    public func flatMapError<NewFailure: Swift.Error>(
        _ transform: (Failure) -> Result<Success, NewFailure>
    ) -> Result<Success, NewFailure> {
        switch self {
        case .success(let value): .success(value)
        case .failure(let error): transform(error)
        }
    }
    
    @inlinable
    public var success: Success? {
        guard case .success(let value) = self else { return nil }
        return value
    }
    
    @inlinable
    public var failure: Failure? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
    
    @inlinable
    public func zip<OtherSuccess>(
        _ other: Result<OtherSuccess, Failure>
    ) -> Result<(Success, OtherSuccess), Failure> {
        switch (self, other) {
        case (.success(let a), .success(let b)):
            return .success((a, b))
            
        case (.failure(let error), _):
            return .failure(error)
            
        case (_, .failure(let error)):
            return .failure(error)
        }
    }
    
    @inlinable
    public func zip<OtherSuccess, Combined>(
        _ other: Result<OtherSuccess, Failure>,
        with combine: (Success, OtherSuccess) -> Combined
    ) -> Result<Combined, Failure> {
        zip(other).map { combine($0.0, $0.1) }
    }
}

extension Swift.Result where Success: Copyable {
    
    @inlinable
    public init(catching body: () throws(Failure) -> Success) {
        do throws(Failure) {
            self = .success(try body())
        } catch {
            self = .failure(error)
        }
    }
}

extension Swift.Result where Success: Copyable {
    
    public enum Builder {
        
        @resultBuilder
        public enum First {
            
            @inlinable
            public static func buildExpression(_ expression: Success) -> Result<Success, Failure> {
                .success(expression)
            }
            
            @inlinable
            public static func buildExpression(
                _ expression: Result<Success, Failure>
            ) -> Result<Success, Failure> {
                expression
            }
            
            @inlinable
            public static func buildPartialBlock(
                first: Result<Success, Failure>
            ) -> Result<Success, Failure> {
                first
            }
            
            @inlinable
            public static func buildPartialBlock(
                first: Result<Success, Failure>?
            ) -> Result<Success, Failure>? {
                first
            }
            
            @inlinable
            public static func buildPartialBlock(first: Void) -> Result<Success, Failure>? {
                nil
            }
            
            @inlinable
            public static func buildPartialBlock(first: Never) -> Result<Success, Failure> {}
            
            @inlinable
            public static func buildPartialBlock(
                accumulated: Result<Success, Failure>,
                next: Result<Success, Failure>
            ) -> Result<Success, Failure> {
                switch accumulated {
                case .success:
                    accumulated
                    
                case .failure:
                    next
                }
            }
            
            @inlinable
            public static func buildPartialBlock(
                accumulated: Result<Success, Failure>,
                next: Result<Success, Failure>?
            ) -> Result<Success, Failure> {
                switch accumulated {
                case .success:
                    accumulated
                    
                case .failure:
                    next ?? accumulated
                }
            }
            
            @inlinable
            public static func buildOptional(
                _ component: Result<Success, Failure>?
            ) -> Result<Success, Failure>? {
                component
            }
            
            @inlinable
            public static func buildEither(
                first: Result<Success, Failure>
            ) -> Result<Success, Failure> {
                first
            }
            
            @inlinable
            public static func buildEither(
                second: Result<Success, Failure>
            ) -> Result<Success, Failure> {
                second
            }
            
            @inlinable
            public static func buildArray(
                _ components: [Result<Success, Failure>]
            ) -> Result<Success, Failure>? {
                var lastFailure: Result<Success, Failure>?
                for component in components {
                    switch component {
                    case .success:
                        return component
                        
                    case .failure:
                        lastFailure = component
                    }
                }
                return lastFailure
            }
            
            @inlinable
            public static func buildLimitedAvailability(
                _ component: Result<Success, Failure>
            ) -> Result<Success, Failure> {
                component
            }
        }
        
        @resultBuilder
        public enum All {
            
            @inlinable
            public static func buildExpression(_ expression: Success) -> Result<[Success], Failure>
            {
                .success([expression])
            }
            
            @inlinable
            public static func buildExpression(
                _ expression: Result<Success, Failure>
            ) -> Result<[Success], Failure> {
                expression.map { [$0] }
            }
            
            @inlinable
            public static func buildPartialBlock(
                first: Result<[Success], Failure>
            ) -> Result<[Success], Failure> {
                first
            }
            
            @inlinable
            public static func buildPartialBlock(first: Void) -> Result<[Success], Failure> {
                .success([])
            }
            
            @inlinable
            public static func buildPartialBlock(first: Never) -> Result<[Success], Failure> {}
            
            @inlinable
            public static func buildPartialBlock(
                accumulated: Result<[Success], Failure>,
                next: Result<[Success], Failure>
            ) -> Result<[Success], Failure> {
                switch (accumulated, next) {
                case (.success(let accValues), .success(let nextValues)):
                        .success(accValues + nextValues)
                    
                case (.failure(let error), _):
                        .failure(error)
                    
                case (_, .failure(let error)):
                        .failure(error)
                }
            }
            
            @inlinable
            public static func buildBlock() -> Result<[Success], Failure> {
                .success([])
            }
            
            @inlinable
            public static func buildOptional(
                _ component: Result<[Success], Failure>?
            ) -> Result<[Success], Failure> {
                component ?? .success([])
            }
            
            @inlinable
            public static func buildEither(
                first: Result<[Success], Failure>
            ) -> Result<[Success], Failure> {
                first
            }
            
            @inlinable
            public static func buildEither(
                second: Result<[Success], Failure>
            ) -> Result<[Success], Failure> {
                second
            }
            
            @inlinable
            public static func buildArray(
                _ components: [Result<[Success], Failure>]
            ) -> Result<[Success], Failure> {
                var collected: [Success] = []
                for component in components {
                    switch component {
                    case .success(let values):
                        collected.append(contentsOf: values)
                        
                    case .failure(let error):
                        return .failure(error)
                    }
                }
                return .success(collected)
            }
            
            @inlinable
            public static func buildLimitedAvailability(
                _ component: Result<[Success], Failure>
            ) -> Result<[Success], Failure> {
                component
            }
        }
    }
}

extension Swift.Result where Success: Copyable {
    
    @inlinable
    public static func first(
        @Builder.First _ builder: () -> Result<Success, Failure>
    ) -> Result<Success, Failure> {
        builder()
    }
    
    @inlinable
    @_disfavoredOverload
    public static func first(
        @Builder.First _ builder: () -> Result<Success, Failure>?
    ) -> Result<Success, Failure>? {
        builder()
    }
    
    @inlinable
    public static func all(
        @Builder.All _ builder: () -> Result<[Success], Failure>
    ) -> Result<[Success], Failure> {
        builder()
    }
}
