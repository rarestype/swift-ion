extension Ion {
    @frozen public struct SymbolEncoder: ~Copyable {
        @usableFromInline var forward: [Ion.Symbol: Ion.Symbol.ID]
        @usableFromInline var symbols: [Ion.Symbol]

        @inlinable public init() {
            self.forward = [:]
            self.symbols = []
        }
    }
}
extension Ion.SymbolEncoder {
    @inlinable init(predefined symbols: [Ion.Symbol]) {
        self.init()

        self.symbols.reserveCapacity(symbols.count)
        self.forward.reserveCapacity(symbols.count)

        for symbol: Ion.Symbol in symbols {
            let id: Ion.Symbol.ID = self[symbol]
            _ = id
        }
    }
}
extension Ion.SymbolEncoder {
    @inlinable var move: Ion.SymbolTable? {
        consuming get {
            if  self.symbols.isEmpty {
                return nil
            }

            return .init(imports: [], symbols: self.symbols)
        }
    }
}
extension Ion.SymbolEncoder {
    @inlinable public subscript(symbol: Ion.Symbol) -> Ion.Symbol.ID {
        mutating get {
            {
                if  let id: Ion.Symbol.ID = $0 {
                    return id
                } else if
                    let id: Ion.Symbol.ID = symbol.system {
                    $0 = id
                    return id
                } else {
                    let id: Ion.Symbol.ID = Ion.Symbol.ID[user: self.symbols.count]
                    self.symbols.append(symbol)
                    $0 = id
                    return id
                }
            } (&self.forward[symbol])
        }
    }
}
