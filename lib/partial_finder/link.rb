# Child should be a string, but parent can be a string or an array
PartialFinder::Link = Struct.new(:child, :parent) do
  def to_s
    "#{child} rendered by #{parent}"
  end
end
