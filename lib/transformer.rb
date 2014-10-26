class TSDTransformer < Parslet::Transform
  rule(id: simple(:x))         { Identifier.new(x.to_s, false) }
  rule(id: simple(:x), nullable: simple(:y)) { Identifier.new(x.to_s, true) }

  rule(type: simple(:x))       { Type.new(x.to_s) }

  rule(decl: subtree(:x))      { Declaration.new(x[:name], x[:ntype]) }
  rule(func_decl: subtree(:x)) { FuncDeclaration.new(x[:name], x[:args], x[:ntype]) }
  rule(fundef: subtree(:x))    { FuncDeclaration.new(x[:name], x[:args], x[:ntype]) }
  rule(attdef: subtree(:x))    { Declaration.new(x[:name], x[:ntype]) }
  rule(arrdef: subtree(:x))    { ArrayDeclaration.new(x[:array][:ntype], x[:ntype]) }
  rule(interface: subtree(:x)) { Interface.new(x[:name], x[:body]) }
end
