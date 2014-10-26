class Type < Struct.new(:type)
  def value
    if type == "string" || type == "number" || type == "bool"
      type.capitalize
    else
      type
    end
  end
end

class Identifier < Struct.new(:id, :nullable)
  def value
    "#{id}"
  end
end

class Declaration < Struct.new(:name, :type)
  def value
    "#{name.value} :: #{type.value}"
  end
end

class FuncDeclaration < Struct.new(:name, :args, :type)
  def value
    targs =
      if args.class == Hash
        args[:ntype].value + " -> "
      elsif args.class == Array
        " -> " + args.map{|x|x[:ntype].value}.join(" -> ") + " -> "
      else
        ""
      end
    "#{name.value} :: #{targs}#{type.value}"
  end
end

class ArrayDeclaration < Struct.new(:arraytype, :type)
  def value
    "[#{arraytype.value}] -> #{type.value}"
  end
end

class Interface < Struct.new(:name, :body)
  def value
    "class #{name.value} where \n    " +
    self.body.map(&:value).join("\n    ")
  end
end
