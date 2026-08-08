internal import Grammar

extension AST {
    /// All of the parsing rules in this library are defined at the UTF-8 level.
    ///
    /// To parse *any* AST value, including fragment values, use ``AST.NodeRule`` instead.
    ///
    /// You can parse AST expressions from any ``Collection`` with an
    /// ``Collection Element`` type of ``UInt8``. For example, you can parse
    /// a ``String`` through its ``String/UTF8View``.
    /**
    ```swift
    let string:String =
    """
    {"success":true,"value":0.1}
    """
    try AST.RootRule<String.Index>.parse(string.utf8)
    ```
    */
    /// However, you could also parse a UTF-8 buffer directly, without
    /// having to convert it to a ``String``.
    /**
    ```swift
    let utf8:[UInt8] =
    [
        123,  34, 115, 117,  99,  99, 101, 115,
        115,  34,  58, 116, 114, 117, 101,  44,
         34, 118,  97, 108, 117, 101,  34,  58,
         48,  46,  49, 125
    ]
    try AST.RootRule<Array<UInt8>.Index>.parse(utf8)
    ```
    */
    /// The generic `Location`
    /// parameter provides this flexibility as a zero-cost abstraction.
    ///
    /// >   Tip:
    ///     The ``/gram`` and ``/swift-ion`` libraries are transparent!
    ///     This means that its parsing rules are always zero-cost abstractions,
    ///     even when applied to third-party collection types, like
    ///     ``/swift-nio/NIOCore/ByteBufferView``.
    enum RootRule<Location> {}
}
extension AST.RootRule: ParsingRule {
    typealias Terminal = UInt8

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws(PatternMatchingError) -> AST.Node
        where Source.Element == Terminal, Source.Index == Location {
        let value: AST.AnyValue
        if  let items: [(AST.Symbol, AST.Node)] = input.parse(
                as: AST.NodeRule<Location>.Object?.self
            ) {
            value = .struct(items)
        } else {
            value = .list(try input.parse(as: AST.NodeRule<Location>.Array.self))
        }
        return .init(types: nil, value: value)
    }
}
