// Generated using Sourcery 1.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


// Generated with SwiftyMocky 4.2.0
// Required Sourcery: 1.8.0


import SwiftyMocky
import XCTest
import HttpKit
import ReactiveSwift
import Combine
import CottonBase
import ReactiveHttpKit
import BrowserNetworking
import FeaturesFlagsKit
import CoreBrowser
@testable import CottonData


// MARK: - JSONRequestEncodable

open class JSONRequestEncodableMock: JSONRequestEncodable, Mock {
    public init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst

    private var queue = DispatchQueue(label: "com.swiftymocky.invocations", qos: .userInteractive)
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }





    open func encodeRequest(_ urlRequest: URLRequestCreatable, with parameters: [String: Any]?) throws -> URLRequest {
        addInvocation(.m_encodeRequest__urlRequestwith_parameters(Parameter<URLRequestCreatable>.value(`urlRequest`), Parameter<[String: Any]?>.value(`parameters`)))
		let perform = methodPerformValue(.m_encodeRequest__urlRequestwith_parameters(Parameter<URLRequestCreatable>.value(`urlRequest`), Parameter<[String: Any]?>.value(`parameters`))) as? (URLRequestCreatable, [String: Any]?) -> Void
		perform?(`urlRequest`, `parameters`)
		var __value: URLRequest
		do {
		    __value = try methodReturnValue(.m_encodeRequest__urlRequestwith_parameters(Parameter<URLRequestCreatable>.value(`urlRequest`), Parameter<[String: Any]?>.value(`parameters`))).casted()
		} catch MockError.notStubed {
			onFatalFailure("Stub return value not specified for encodeRequest(_ urlRequest: URLRequestCreatable, with parameters: [String: Any]?). Use given")
			Failure("Stub return value not specified for encodeRequest(_ urlRequest: URLRequestCreatable, with parameters: [String: Any]?). Use given")
		} catch {
		    throw error
		}
		return __value
    }


    fileprivate enum MethodType {
        case m_encodeRequest__urlRequestwith_parameters(Parameter<URLRequestCreatable>, Parameter<[String: Any]?>)

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Matcher.ComparisonResult {
            switch (lhs, rhs) {
            case (.m_encodeRequest__urlRequestwith_parameters(let lhsUrlrequest, let lhsParameters), .m_encodeRequest__urlRequestwith_parameters(let rhsUrlrequest, let rhsParameters)):
				var results: [Matcher.ParameterComparisonResult] = []
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsUrlrequest, rhs: rhsUrlrequest, with: matcher), lhsUrlrequest, rhsUrlrequest, "_ urlRequest"))
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsParameters, rhs: rhsParameters, with: matcher), lhsParameters, rhsParameters, "with parameters"))
				return Matcher.ComparisonResult(results)
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_encodeRequest__urlRequestwith_parameters(p0, p1): return p0.intValue + p1.intValue
            }
        }
        func assertionName() -> String {
            switch self {
            case .m_encodeRequest__urlRequestwith_parameters: return ".encodeRequest(_:with:)"
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


        public static func encodeRequest(_ urlRequest: Parameter<URLRequestCreatable>, with parameters: Parameter<[String: Any]?>, willReturn: URLRequest...) -> MethodStub {
            return Given(method: .m_encodeRequest__urlRequestwith_parameters(`urlRequest`, `parameters`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func encodeRequest(_ urlRequest: Parameter<URLRequestCreatable>, with parameters: Parameter<[String: Any]?>, willThrow: Error...) -> MethodStub {
            return Given(method: .m_encodeRequest__urlRequestwith_parameters(`urlRequest`, `parameters`), products: willThrow.map({ StubProduct.throw($0) }))
        }
        public static func encodeRequest(_ urlRequest: Parameter<URLRequestCreatable>, with parameters: Parameter<[String: Any]?>, willProduce: (StubberThrows<URLRequest>) -> Void) -> MethodStub {
            let willThrow: [Error] = []
			let given: Given = { return Given(method: .m_encodeRequest__urlRequestwith_parameters(`urlRequest`, `parameters`), products: willThrow.map({ StubProduct.throw($0) })) }()
			let stubber = given.stubThrows(for: (URLRequest).self)
			willProduce(stubber)
			return given
        }
    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func encodeRequest(_ urlRequest: Parameter<URLRequestCreatable>, with parameters: Parameter<[String: Any]?>) -> Verify { return Verify(method: .m_encodeRequest__urlRequestwith_parameters(`urlRequest`, `parameters`))}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func encodeRequest(_ urlRequest: Parameter<URLRequestCreatable>, with parameters: Parameter<[String: Any]?>, perform: @escaping (URLRequestCreatable, [String: Any]?) -> Void) -> Perform {
            return Perform(method: .m_encodeRequest__urlRequestwith_parameters(`urlRequest`, `parameters`), performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let fullMatches = matchingCalls(method, file: file, line: line)
        let success = count.matches(fullMatches)
        let assertionName = method.method.assertionName()
        let feedback: String = {
            guard !success else { return "" }
            return Utils.closestCallsMessage(
                for: self.invocations.map { invocation in
                    matcher.set(file: file, line: line)
                    defer { matcher.clearFileAndLine() }
                    return MethodType.compareParameters(lhs: invocation, rhs: method.method, matcher: matcher)
                },
                name: assertionName
            )
        }()
        MockyAssert(success, "Expected: \(count) invocations of `\(assertionName)`, but was: \(fullMatches).\(feedback)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        self.queue.sync { invocations.append(call) }
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType, file: StaticString?, line: UInt?) -> [MethodType] {
        matcher.set(file: file ?? self.file, line: line ?? self.line)
        defer { matcher.clearFileAndLine() }
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher).isFullMatch }
    }
    private func matchingCalls(_ method: Verify, file: StaticString?, line: UInt?) -> Int {
        return matchingCalls(method.method, file: file, line: line).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleFatalError(message: message, file: file, line: line)
    }
}

// MARK: - KnownDomainsSource

open class KnownDomainsSourceMock: KnownDomainsSource, Mock {
    public init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst

    private var queue = DispatchQueue(label: "com.swiftymocky.invocations", qos: .userInteractive)
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }





    open func domainNames(whereURLContains filter: String) -> [String] {
        addInvocation(.m_domainNames__whereURLContains_filter(Parameter<String>.value(`filter`)))
		let perform = methodPerformValue(.m_domainNames__whereURLContains_filter(Parameter<String>.value(`filter`))) as? (String) -> Void
		perform?(`filter`)
		var __value: [String]
		do {
		    __value = try methodReturnValue(.m_domainNames__whereURLContains_filter(Parameter<String>.value(`filter`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for domainNames(whereURLContains filter: String). Use given")
			Failure("Stub return value not specified for domainNames(whereURLContains filter: String). Use given")
		}
		return __value
    }


    fileprivate enum MethodType {
        case m_domainNames__whereURLContains_filter(Parameter<String>)

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Matcher.ComparisonResult {
            switch (lhs, rhs) {
            case (.m_domainNames__whereURLContains_filter(let lhsFilter), .m_domainNames__whereURLContains_filter(let rhsFilter)):
				var results: [Matcher.ParameterComparisonResult] = []
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsFilter, rhs: rhsFilter, with: matcher), lhsFilter, rhsFilter, "whereURLContains filter"))
				return Matcher.ComparisonResult(results)
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_domainNames__whereURLContains_filter(p0): return p0.intValue
            }
        }
        func assertionName() -> String {
            switch self {
            case .m_domainNames__whereURLContains_filter: return ".domainNames(whereURLContains:)"
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


        public static func domainNames(whereURLContains filter: Parameter<String>, willReturn: [String]...) -> MethodStub {
            return Given(method: .m_domainNames__whereURLContains_filter(`filter`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func domainNames(whereURLContains filter: Parameter<String>, willProduce: (Stubber<[String]>) -> Void) -> MethodStub {
            let willReturn: [[String]] = []
			let given: Given = { return Given(method: .m_domainNames__whereURLContains_filter(`filter`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: ([String]).self)
			willProduce(stubber)
			return given
        }
    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func domainNames(whereURLContains filter: Parameter<String>) -> Verify { return Verify(method: .m_domainNames__whereURLContains_filter(`filter`))}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func domainNames(whereURLContains filter: Parameter<String>, perform: @escaping (String) -> Void) -> Perform {
            return Perform(method: .m_domainNames__whereURLContains_filter(`filter`), performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let fullMatches = matchingCalls(method, file: file, line: line)
        let success = count.matches(fullMatches)
        let assertionName = method.method.assertionName()
        let feedback: String = {
            guard !success else { return "" }
            return Utils.closestCallsMessage(
                for: self.invocations.map { invocation in
                    matcher.set(file: file, line: line)
                    defer { matcher.clearFileAndLine() }
                    return MethodType.compareParameters(lhs: invocation, rhs: method.method, matcher: matcher)
                },
                name: assertionName
            )
        }()
        MockyAssert(success, "Expected: \(count) invocations of `\(assertionName)`, but was: \(fullMatches).\(feedback)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        self.queue.sync { invocations.append(call) }
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType, file: StaticString?, line: UInt?) -> [MethodType] {
        matcher.set(file: file ?? self.file, line: line ?? self.line)
        defer { matcher.clearFileAndLine() }
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher).isFullMatch }
    }
    private func matchingCalls(_ method: Verify, file: StaticString?, line: UInt?) -> Int {
        return matchingCalls(method.method, file: file, line: line).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleFatalError(message: message, file: file, line: line)
    }
}

// MARK: - NetworkReachabilityAdapter

open class NetworkReachabilityAdapterMock<Server>: NetworkReachabilityAdapter, Mock where Server: ServerDescription {
    public init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst

    private var queue = DispatchQueue(label: "com.swiftymocky.invocations", qos: .userInteractive)
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }





    public required init?(server: Server) { }

    @discardableResult
	open func startListening(onQueue queue: DispatchQueue, onUpdatePerforming listener: @escaping Listener) -> Bool {
        addInvocation(.m_startListening__onQueue_queueonUpdatePerforming_listener(Parameter<DispatchQueue>.value(`queue`), Parameter<Listener>.any))
		let perform = methodPerformValue(.m_startListening__onQueue_queueonUpdatePerforming_listener(Parameter<DispatchQueue>.value(`queue`), Parameter<Listener>.any)) as? (DispatchQueue, @escaping Listener) -> Void
		perform?(`queue`, `listener`)
		var __value: Bool
		do {
		    __value = try methodReturnValue(.m_startListening__onQueue_queueonUpdatePerforming_listener(Parameter<DispatchQueue>.value(`queue`), Parameter<Listener>.any)).casted()
		} catch {
			onFatalFailure("Stub return value not specified for startListening(onQueue queue: DispatchQueue, onUpdatePerforming listener: @escaping Listener). Use given")
			Failure("Stub return value not specified for startListening(onQueue queue: DispatchQueue, onUpdatePerforming listener: @escaping Listener). Use given")
		}
		return __value
    }

    open func stopListening() {
        addInvocation(.m_stopListening)
		let perform = methodPerformValue(.m_stopListening) as? () -> Void
		perform?()
    }


    fileprivate enum MethodType {
        case m_startListening__onQueue_queueonUpdatePerforming_listener(Parameter<DispatchQueue>, Parameter<Listener>)
        case m_stopListening

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Matcher.ComparisonResult {
            switch (lhs, rhs) {
            case (.m_startListening__onQueue_queueonUpdatePerforming_listener(let lhsQueue, let lhsListener), .m_startListening__onQueue_queueonUpdatePerforming_listener(let rhsQueue, let rhsListener)):
				var results: [Matcher.ParameterComparisonResult] = []
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsQueue, rhs: rhsQueue, with: matcher), lhsQueue, rhsQueue, "onQueue queue"))
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsListener, rhs: rhsListener, with: matcher), lhsListener, rhsListener, "onUpdatePerforming listener"))
				return Matcher.ComparisonResult(results)

            case (.m_stopListening, .m_stopListening): return .match
            default: return .none
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_startListening__onQueue_queueonUpdatePerforming_listener(p0, p1): return p0.intValue + p1.intValue
            case .m_stopListening: return 0
            }
        }
        func assertionName() -> String {
            switch self {
            case .m_startListening__onQueue_queueonUpdatePerforming_listener: return ".startListening(onQueue:onUpdatePerforming:)"
            case .m_stopListening: return ".stopListening()"
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


        @discardableResult
		public static func startListening(onQueue queue: Parameter<DispatchQueue>, onUpdatePerforming listener: Parameter<Listener>, willReturn: Bool...) -> MethodStub {
            return Given(method: .m_startListening__onQueue_queueonUpdatePerforming_listener(`queue`, `listener`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        @discardableResult
		public static func startListening(onQueue queue: Parameter<DispatchQueue>, onUpdatePerforming listener: Parameter<Listener>, willProduce: (Stubber<Bool>) -> Void) -> MethodStub {
            let willReturn: [Bool] = []
			let given: Given = { return Given(method: .m_startListening__onQueue_queueonUpdatePerforming_listener(`queue`, `listener`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (Bool).self)
			willProduce(stubber)
			return given
        }
    }

    public struct Verify {
        fileprivate var method: MethodType

        @discardableResult
		public static func startListening(onQueue queue: Parameter<DispatchQueue>, onUpdatePerforming listener: Parameter<Listener>) -> Verify { return Verify(method: .m_startListening__onQueue_queueonUpdatePerforming_listener(`queue`, `listener`))}
        public static func stopListening() -> Verify { return Verify(method: .m_stopListening)}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        @discardableResult
		public static func startListening(onQueue queue: Parameter<DispatchQueue>, onUpdatePerforming listener: Parameter<Listener>, perform: @escaping (DispatchQueue, @escaping Listener) -> Void) -> Perform {
            return Perform(method: .m_startListening__onQueue_queueonUpdatePerforming_listener(`queue`, `listener`), performs: perform)
        }
        public static func stopListening(perform: @escaping () -> Void) -> Perform {
            return Perform(method: .m_stopListening, performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let fullMatches = matchingCalls(method, file: file, line: line)
        let success = count.matches(fullMatches)
        let assertionName = method.method.assertionName()
        let feedback: String = {
            guard !success else { return "" }
            return Utils.closestCallsMessage(
                for: self.invocations.map { invocation in
                    matcher.set(file: file, line: line)
                    defer { matcher.clearFileAndLine() }
                    return MethodType.compareParameters(lhs: invocation, rhs: method.method, matcher: matcher)
                },
                name: assertionName
            )
        }()
        MockyAssert(success, "Expected: \(count) invocations of `\(assertionName)`, but was: \(fullMatches).\(feedback)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        self.queue.sync { invocations.append(call) }
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType, file: StaticString?, line: UInt?) -> [MethodType] {
        matcher.set(file: file ?? self.file, line: line ?? self.line)
        defer { matcher.clearFileAndLine() }
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher).isFullMatch }
    }
    private func matchingCalls(_ method: Verify, file: StaticString?, line: UInt?) -> Int {
        return matchingCalls(method.method, file: file, line: line).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleFatalError(message: message, file: file, line: line)
    }
}

// MARK: - RestClientContext

open class RestClientContextMock<R,S,RA,E,C>: RestClientContext, Mock where R: ResponseType, S: ServerDescription, RA: NetworkReachabilityAdapter, RA.Server == S, E: JSONRequestEncodable, C: RestInterface, C.Reachability == RA, C.Encoder == E {
    public init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst

    private var queue = DispatchQueue(label: "com.swiftymocky.invocations", qos: .userInteractive)
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given
    public typealias Response = R
    public typealias Server = S
    public typealias ReachabilityAdapter = RA
    public typealias Encoder = E
    public typealias Client = C

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }

    public var client: Client {
		get {	invocations.append(.p_client_get); return __p_client ?? givenGetterValue(.p_client_get, "RestClientContextMock - stub value for client was not defined") }
	}
	private var __p_client: (Client)?

    public var rxSubscriber: HttpKitRxSubscriber {
		get {	invocations.append(.p_rxSubscriber_get); return __p_rxSubscriber ?? givenGetterValue(.p_rxSubscriber_get, "RestClientContextMock - stub value for rxSubscriber was not defined") }
	}
	private var __p_rxSubscriber: (HttpKitRxSubscriber)?

    public var subscriber: HttpKitSubscriber {
		get {	invocations.append(.p_subscriber_get); return __p_subscriber ?? givenGetterValue(.p_subscriber_get, "RestClientContextMock - stub value for subscriber was not defined") }
	}
	private var __p_subscriber: (HttpKitSubscriber)?





    public required init(_ client: Client, _ rxSubscriber: HttpKitRxSubscriber, _ subscriber: HttpKitSubscriber) { }


    fileprivate enum MethodType {
        case p_client_get
        case p_rxSubscriber_get
        case p_subscriber_get

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Matcher.ComparisonResult {
            switch (lhs, rhs) {            case (.p_client_get,.p_client_get): return Matcher.ComparisonResult.match
            case (.p_rxSubscriber_get,.p_rxSubscriber_get): return Matcher.ComparisonResult.match
            case (.p_subscriber_get,.p_subscriber_get): return Matcher.ComparisonResult.match
            default: return .none
            }
        }

        func intValue() -> Int {
            switch self {
            case .p_client_get: return 0
            case .p_rxSubscriber_get: return 0
            case .p_subscriber_get: return 0
            }
        }
        func assertionName() -> String {
            switch self {
            case .p_client_get: return "[get] .client"
            case .p_rxSubscriber_get: return "[get] .rxSubscriber"
            case .p_subscriber_get: return "[get] .subscriber"
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }

        public static func client(getter defaultValue: Client...) -> PropertyStub {
            return Given(method: .p_client_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func rxSubscriber(getter defaultValue: HttpKitRxSubscriber...) -> PropertyStub {
            return Given(method: .p_rxSubscriber_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func subscriber(getter defaultValue: HttpKitSubscriber...) -> PropertyStub {
            return Given(method: .p_subscriber_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }

    }

    public struct Verify {
        fileprivate var method: MethodType

        public static var client: Verify { return Verify(method: .p_client_get) }
        public static var rxSubscriber: Verify { return Verify(method: .p_rxSubscriber_get) }
        public static var subscriber: Verify { return Verify(method: .p_subscriber_get) }
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let fullMatches = matchingCalls(method, file: file, line: line)
        let success = count.matches(fullMatches)
        let assertionName = method.method.assertionName()
        let feedback: String = {
            guard !success else { return "" }
            return Utils.closestCallsMessage(
                for: self.invocations.map { invocation in
                    matcher.set(file: file, line: line)
                    defer { matcher.clearFileAndLine() }
                    return MethodType.compareParameters(lhs: invocation, rhs: method.method, matcher: matcher)
                },
                name: assertionName
            )
        }()
        MockyAssert(success, "Expected: \(count) invocations of `\(assertionName)`, but was: \(fullMatches).\(feedback)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        self.queue.sync { invocations.append(call) }
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType, file: StaticString?, line: UInt?) -> [MethodType] {
        matcher.set(file: file ?? self.file, line: line ?? self.line)
        defer { matcher.clearFileAndLine() }
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher).isFullMatch }
    }
    private func matchingCalls(_ method: Verify, file: StaticString?, line: UInt?) -> Int {
        return matchingCalls(method.method, file: file, line: line).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleFatalError(message: message, file: file, line: line)
    }
}

// MARK: - RestInterface

open class RestInterfaceMock<S,RA,E>: RestInterface, Mock where S: ServerDescription, RA: NetworkReachabilityAdapter, RA.Server == S, E: JSONRequestEncodable {
    public init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst

    private var queue = DispatchQueue(label: "com.swiftymocky.invocations", qos: .userInteractive)
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given
    public typealias Server = S
    public typealias Reachability = RA
    public typealias Encoder = E

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }

    public var server: Server {
		get {	invocations.append(.p_server_get); return __p_server ?? givenGetterValue(.p_server_get, "RestInterfaceMock - stub value for server was not defined") }
	}
	private var __p_server: (Server)?

    public var jsonEncoder: Encoder {
		get {	invocations.append(.p_jsonEncoder_get); return __p_jsonEncoder ?? givenGetterValue(.p_jsonEncoder_get, "RestInterfaceMock - stub value for jsonEncoder was not defined") }
	}
	private var __p_jsonEncoder: (Encoder)?





    public required init(server: Server, jsonEncoder: Encoder, reachability: Reachability, httpTimeout: TimeInterval) { }


    fileprivate enum MethodType {
        case p_server_get
        case p_jsonEncoder_get

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Matcher.ComparisonResult {
            switch (lhs, rhs) {            case (.p_server_get,.p_server_get): return Matcher.ComparisonResult.match
            case (.p_jsonEncoder_get,.p_jsonEncoder_get): return Matcher.ComparisonResult.match
            default: return .none
            }
        }

        func intValue() -> Int {
            switch self {
            case .p_server_get: return 0
            case .p_jsonEncoder_get: return 0
            }
        }
        func assertionName() -> String {
            switch self {
            case .p_server_get: return "[get] .server"
            case .p_jsonEncoder_get: return "[get] .jsonEncoder"
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }

        public static func server(getter defaultValue: Server...) -> PropertyStub {
            return Given(method: .p_server_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func jsonEncoder(getter defaultValue: Encoder...) -> PropertyStub {
            return Given(method: .p_jsonEncoder_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }

    }

    public struct Verify {
        fileprivate var method: MethodType

        public static var server: Verify { return Verify(method: .p_server_get) }
        public static var jsonEncoder: Verify { return Verify(method: .p_jsonEncoder_get) }
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let fullMatches = matchingCalls(method, file: file, line: line)
        let success = count.matches(fullMatches)
        let assertionName = method.method.assertionName()
        let feedback: String = {
            guard !success else { return "" }
            return Utils.closestCallsMessage(
                for: self.invocations.map { invocation in
                    matcher.set(file: file, line: line)
                    defer { matcher.clearFileAndLine() }
                    return MethodType.compareParameters(lhs: invocation, rhs: method.method, matcher: matcher)
                },
                name: assertionName
            )
        }()
        MockyAssert(success, "Expected: \(count) invocations of `\(assertionName)`, but was: \(fullMatches).\(feedback)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        self.queue.sync { invocations.append(call) }
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType, file: StaticString?, line: UInt?) -> [MethodType] {
        matcher.set(file: file ?? self.file, line: line ?? self.line)
        defer { matcher.clearFileAndLine() }
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher).isFullMatch }
    }
    private func matchingCalls(_ method: Verify, file: StaticString?, line: UInt?) -> Int {
        return matchingCalls(method.method, file: file, line: line).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleFatalError(message: message, file: file, line: line)
    }
}

// MARK: - SearchAutocompleteStrategy

open class SearchAutocompleteStrategyMock<Context>: SearchAutocompleteStrategy, Mock where Context: RestClientContext {
    public init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst

    private var queue = DispatchQueue(label: "com.swiftymocky.invocations", qos: .userInteractive)
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }





    public required init(_ context: Context) { }

    open func suggestionsProducer(for text: String) -> SignalProducer<SearchSuggestionsResponse, HttpError> {
        addInvocation(.m_suggestionsProducer__for_text(Parameter<String>.value(`text`)))
		let perform = methodPerformValue(.m_suggestionsProducer__for_text(Parameter<String>.value(`text`))) as? (String) -> Void
		perform?(`text`)
		var __value: SignalProducer<SearchSuggestionsResponse, HttpError>
		do {
		    __value = try methodReturnValue(.m_suggestionsProducer__for_text(Parameter<String>.value(`text`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for suggestionsProducer(for text: String). Use given")
			Failure("Stub return value not specified for suggestionsProducer(for text: String). Use given")
		}
		return __value
    }

    open func suggestionsPublisher(for text: String) -> AnyPublisher<SearchSuggestionsResponse, HttpError> {
        addInvocation(.m_suggestionsPublisher__for_text(Parameter<String>.value(`text`)))
		let perform = methodPerformValue(.m_suggestionsPublisher__for_text(Parameter<String>.value(`text`))) as? (String) -> Void
		perform?(`text`)
		var __value: AnyPublisher<SearchSuggestionsResponse, HttpError>
		do {
		    __value = try methodReturnValue(.m_suggestionsPublisher__for_text(Parameter<String>.value(`text`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for suggestionsPublisher(for text: String). Use given")
			Failure("Stub return value not specified for suggestionsPublisher(for text: String). Use given")
		}
		return __value
    }

    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *) @available(swift 5.5)
	open func suggestionsTask(for text: String) throws -> SearchSuggestionsResponse {
        addInvocation(.m_suggestionsTask__for_text(Parameter<String>.value(`text`).typeErasedAttribute()))
		let perform = methodPerformValue(.m_suggestionsTask__for_text(Parameter<String>.value(`text`).typeErasedAttribute())) as? (String) -> Void
		perform?(`text`)
		var __value: SearchSuggestionsResponse
		do {
		    __value = try methodReturnValue(.m_suggestionsTask__for_text(Parameter<String>.value(`text`).typeErasedAttribute())).casted()
		} catch MockError.notStubed {
			onFatalFailure("Stub return value not specified for suggestionsTask(for text: String). Use given")
			Failure("Stub return value not specified for suggestionsTask(for text: String). Use given")
		} catch {
		    throw error
		}
		return __value
    }


    fileprivate enum MethodType {
        case m_suggestionsProducer__for_text(Parameter<String>)
        case m_suggestionsPublisher__for_text(Parameter<String>)
        case m_suggestionsTask__for_text(Parameter<TypeErasedAttribute>)

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Matcher.ComparisonResult {
            switch (lhs, rhs) {
            case (.m_suggestionsProducer__for_text(let lhsText), .m_suggestionsProducer__for_text(let rhsText)):
				var results: [Matcher.ParameterComparisonResult] = []
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsText, rhs: rhsText, with: matcher), lhsText, rhsText, "for text"))
				return Matcher.ComparisonResult(results)

            case (.m_suggestionsPublisher__for_text(let lhsText), .m_suggestionsPublisher__for_text(let rhsText)):
				var results: [Matcher.ParameterComparisonResult] = []
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsText, rhs: rhsText, with: matcher), lhsText, rhsText, "for text"))
				return Matcher.ComparisonResult(results)

            case (.m_suggestionsTask__for_text(let lhsText), .m_suggestionsTask__for_text(let rhsText)):
				var results: [Matcher.ParameterComparisonResult] = []
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsText, rhs: rhsText, with: matcher), lhsText, rhsText, "for text"))
				return Matcher.ComparisonResult(results)
            default: return .none
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_suggestionsProducer__for_text(p0): return p0.intValue
            case let .m_suggestionsPublisher__for_text(p0): return p0.intValue
            case let .m_suggestionsTask__for_text(p0): return p0.intValue
            }
        }
        func assertionName() -> String {
            switch self {
            case .m_suggestionsProducer__for_text: return ".suggestionsProducer(for:)"
            case .m_suggestionsPublisher__for_text: return ".suggestionsPublisher(for:)"
            case .m_suggestionsTask__for_text: return ".suggestionsTask(for:)"
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


        public static func suggestionsProducer(for text: Parameter<String>, willReturn: SignalProducer<SearchSuggestionsResponse, HttpError>...) -> MethodStub {
            return Given(method: .m_suggestionsProducer__for_text(`text`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func suggestionsPublisher(for text: Parameter<String>, willReturn: AnyPublisher<SearchSuggestionsResponse, HttpError>...) -> MethodStub {
            return Given(method: .m_suggestionsPublisher__for_text(`text`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *) @available(swift 5.5)
		public static func suggestionsTask(for text: Parameter<String>, willReturn: SearchSuggestionsResponse...) -> MethodStub {
            return Given(method: .m_suggestionsTask__for_text(`text`.typeErasedAttribute()), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func suggestionsProducer(for text: Parameter<String>, willProduce: (Stubber<SignalProducer<SearchSuggestionsResponse, HttpError>>) -> Void) -> MethodStub {
            let willReturn: [SignalProducer<SearchSuggestionsResponse, HttpError>] = []
			let given: Given = { return Given(method: .m_suggestionsProducer__for_text(`text`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (SignalProducer<SearchSuggestionsResponse, HttpError>).self)
			willProduce(stubber)
			return given
        }
        public static func suggestionsPublisher(for text: Parameter<String>, willProduce: (Stubber<AnyPublisher<SearchSuggestionsResponse, HttpError>>) -> Void) -> MethodStub {
            let willReturn: [AnyPublisher<SearchSuggestionsResponse, HttpError>] = []
			let given: Given = { return Given(method: .m_suggestionsPublisher__for_text(`text`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (AnyPublisher<SearchSuggestionsResponse, HttpError>).self)
			willProduce(stubber)
			return given
        }
        @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *) @available(swift 5.5)
		public static func suggestionsTask(for text: Parameter<String>, willThrow: Error...) -> MethodStub {
            return Given(method: .m_suggestionsTask__for_text(`text`.typeErasedAttribute()), products: willThrow.map({ StubProduct.throw($0) }))
        }
        @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *) @available(swift 5.5)
		public static func suggestionsTask(for text: Parameter<String>, willProduce: (StubberThrows<SearchSuggestionsResponse>) -> Void) -> MethodStub {
            let willThrow: [Error] = []
			let given: Given = { return Given(method: .m_suggestionsTask__for_text(`text`.typeErasedAttribute()), products: willThrow.map({ StubProduct.throw($0) })) }()
			let stubber = given.stubThrows(for: (SearchSuggestionsResponse).self)
			willProduce(stubber)
			return given
        }
    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func suggestionsProducer(for text: Parameter<String>) -> Verify { return Verify(method: .m_suggestionsProducer__for_text(`text`))}
        public static func suggestionsPublisher(for text: Parameter<String>) -> Verify { return Verify(method: .m_suggestionsPublisher__for_text(`text`))}
        @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *) @available(swift 5.5)
		public static func suggestionsTask(for text: Parameter<String>) -> Verify { return Verify(method: .m_suggestionsTask__for_text(`text`.typeErasedAttribute()))}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func suggestionsProducer(for text: Parameter<String>, perform: @escaping (String) -> Void) -> Perform {
            return Perform(method: .m_suggestionsProducer__for_text(`text`), performs: perform)
        }
        public static func suggestionsPublisher(for text: Parameter<String>, perform: @escaping (String) -> Void) -> Perform {
            return Perform(method: .m_suggestionsPublisher__for_text(`text`), performs: perform)
        }
        @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *) @available(swift 5.5)
		public static func suggestionsTask(for text: Parameter<String>, perform: @escaping (String) -> Void) -> Perform {
            return Perform(method: .m_suggestionsTask__for_text(`text`.typeErasedAttribute()), performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let fullMatches = matchingCalls(method, file: file, line: line)
        let success = count.matches(fullMatches)
        let assertionName = method.method.assertionName()
        let feedback: String = {
            guard !success else { return "" }
            return Utils.closestCallsMessage(
                for: self.invocations.map { invocation in
                    matcher.set(file: file, line: line)
                    defer { matcher.clearFileAndLine() }
                    return MethodType.compareParameters(lhs: invocation, rhs: method.method, matcher: matcher)
                },
                name: assertionName
            )
        }()
        MockyAssert(success, "Expected: \(count) invocations of `\(assertionName)`, but was: \(fullMatches).\(feedback)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        self.queue.sync { invocations.append(call) }
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType, file: StaticString?, line: UInt?) -> [MethodType] {
        matcher.set(file: file ?? self.file, line: line ?? self.line)
        defer { matcher.clearFileAndLine() }
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher).isFullMatch }
    }
    private func matchingCalls(_ method: Verify, file: StaticString?, line: UInt?) -> Int {
        return matchingCalls(method.method, file: file, line: line).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleFatalError(message: message, file: file, line: line)
    }
}

// MARK: - SearchViewContext

open class SearchViewContextMock: SearchViewContext, Mock {
    public init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst

    private var queue = DispatchQueue(label: "com.swiftymocky.invocations", qos: .userInteractive)
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }

    public var appAsyncApiTypeValue: AsyncApiType {
		get {	invocations.append(.p_appAsyncApiTypeValue_get); return __p_appAsyncApiTypeValue ?? givenGetterValue(.p_appAsyncApiTypeValue_get, "SearchViewContextMock - stub value for appAsyncApiTypeValue was not defined") }
	}
	private var __p_appAsyncApiTypeValue: (AsyncApiType)?

    public var knownDomainsStorage: KnownDomainsSource {
		get {	invocations.append(.p_knownDomainsStorage_get); return __p_knownDomainsStorage ?? givenGetterValue(.p_knownDomainsStorage_get, "SearchViewContextMock - stub value for knownDomainsStorage was not defined") }
	}
	private var __p_knownDomainsStorage: (KnownDomainsSource)?






    fileprivate enum MethodType {
        case p_appAsyncApiTypeValue_get
        case p_knownDomainsStorage_get

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Matcher.ComparisonResult {
            switch (lhs, rhs) {            case (.p_appAsyncApiTypeValue_get,.p_appAsyncApiTypeValue_get): return Matcher.ComparisonResult.match
            case (.p_knownDomainsStorage_get,.p_knownDomainsStorage_get): return Matcher.ComparisonResult.match
            default: return .none
            }
        }

        func intValue() -> Int {
            switch self {
            case .p_appAsyncApiTypeValue_get: return 0
            case .p_knownDomainsStorage_get: return 0
            }
        }
        func assertionName() -> String {
            switch self {
            case .p_appAsyncApiTypeValue_get: return "[get] .appAsyncApiTypeValue"
            case .p_knownDomainsStorage_get: return "[get] .knownDomainsStorage"
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }

        public static func appAsyncApiTypeValue(getter defaultValue: AsyncApiType...) -> PropertyStub {
            return Given(method: .p_appAsyncApiTypeValue_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func knownDomainsStorage(getter defaultValue: KnownDomainsSource...) -> PropertyStub {
            return Given(method: .p_knownDomainsStorage_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }

    }

    public struct Verify {
        fileprivate var method: MethodType

        public static var appAsyncApiTypeValue: Verify { return Verify(method: .p_appAsyncApiTypeValue_get) }
        public static var knownDomainsStorage: Verify { return Verify(method: .p_knownDomainsStorage_get) }
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let fullMatches = matchingCalls(method, file: file, line: line)
        let success = count.matches(fullMatches)
        let assertionName = method.method.assertionName()
        let feedback: String = {
            guard !success else { return "" }
            return Utils.closestCallsMessage(
                for: self.invocations.map { invocation in
                    matcher.set(file: file, line: line)
                    defer { matcher.clearFileAndLine() }
                    return MethodType.compareParameters(lhs: invocation, rhs: method.method, matcher: matcher)
                },
                name: assertionName
            )
        }()
        MockyAssert(success, "Expected: \(count) invocations of `\(assertionName)`, but was: \(fullMatches).\(feedback)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        self.queue.sync { invocations.append(call) }
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType, file: StaticString?, line: UInt?) -> [MethodType] {
        matcher.set(file: file ?? self.file, line: line ?? self.line)
        defer { matcher.clearFileAndLine() }
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher).isFullMatch }
    }
    private func matchingCalls(_ method: Verify, file: StaticString?, line: UInt?) -> Int {
        return matchingCalls(method.method, file: file, line: line).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleFatalError(message: message, file: file, line: line)
    }
}

// MARK: - URLRequestCreatable

open class URLRequestCreatableMock: URLRequestCreatable, Mock {
    public init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst

    private var queue = DispatchQueue(label: "com.swiftymocky.invocations", qos: .userInteractive)
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }





    open func convertToURLRequest() throws -> URLRequest {
        addInvocation(.m_convertToURLRequest)
		let perform = methodPerformValue(.m_convertToURLRequest) as? () -> Void
		perform?()
		var __value: URLRequest
		do {
		    __value = try methodReturnValue(.m_convertToURLRequest).casted()
		} catch MockError.notStubed {
			onFatalFailure("Stub return value not specified for convertToURLRequest(). Use given")
			Failure("Stub return value not specified for convertToURLRequest(). Use given")
		} catch {
		    throw error
		}
		return __value
    }


    fileprivate enum MethodType {
        case m_convertToURLRequest

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Matcher.ComparisonResult {
            switch (lhs, rhs) {
            case (.m_convertToURLRequest, .m_convertToURLRequest): return .match
            }
        }

        func intValue() -> Int {
            switch self {
            case .m_convertToURLRequest: return 0
            }
        }
        func assertionName() -> String {
            switch self {
            case .m_convertToURLRequest: return ".convertToURLRequest()"
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


        public static func convertToURLRequest(willReturn: URLRequest...) -> MethodStub {
            return Given(method: .m_convertToURLRequest, products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func convertToURLRequest(willThrow: Error...) -> MethodStub {
            return Given(method: .m_convertToURLRequest, products: willThrow.map({ StubProduct.throw($0) }))
        }
        public static func convertToURLRequest(willProduce: (StubberThrows<URLRequest>) -> Void) -> MethodStub {
            let willThrow: [Error] = []
			let given: Given = { return Given(method: .m_convertToURLRequest, products: willThrow.map({ StubProduct.throw($0) })) }()
			let stubber = given.stubThrows(for: (URLRequest).self)
			willProduce(stubber)
			return given
        }
    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func convertToURLRequest() -> Verify { return Verify(method: .m_convertToURLRequest)}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func convertToURLRequest(perform: @escaping () -> Void) -> Perform {
            return Perform(method: .m_convertToURLRequest, performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let fullMatches = matchingCalls(method, file: file, line: line)
        let success = count.matches(fullMatches)
        let assertionName = method.method.assertionName()
        let feedback: String = {
            guard !success else { return "" }
            return Utils.closestCallsMessage(
                for: self.invocations.map { invocation in
                    matcher.set(file: file, line: line)
                    defer { matcher.clearFileAndLine() }
                    return MethodType.compareParameters(lhs: invocation, rhs: method.method, matcher: matcher)
                },
                name: assertionName
            )
        }()
        MockyAssert(success, "Expected: \(count) invocations of `\(assertionName)`, but was: \(fullMatches).\(feedback)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        self.queue.sync { invocations.append(call) }
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        matcher.set(file: self.file, line: self.line)
        defer { matcher.clearFileAndLine() }
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType, file: StaticString?, line: UInt?) -> [MethodType] {
        matcher.set(file: file ?? self.file, line: line ?? self.line)
        defer { matcher.clearFileAndLine() }
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher).isFullMatch }
    }
    private func matchingCalls(_ method: Verify, file: StaticString?, line: UInt?) -> Int {
        return matchingCalls(method.method, file: file, line: line).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleFatalError(message: message, file: file, line: line)
    }
}

