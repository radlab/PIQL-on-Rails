# Piqled

module PIQLEntity
  def method_missing(symbol, *args)
    str = symbol.to_s
    if str[-1] == '='[0]
      self.put(str[0..-2], args[0])
    end
  end
end

def get_piql_classes(path = PIQL_JAR_PATH)
  jar = JarFile.new(path)
  jar.entries.map { |entry| 
    entry.getName.match(/^(piql\/[a-zA-Z0-9]*).class$/) }.select {
    |re| re}.map { |re| re[1].sub('/', '.')}
end
  
def include_piql(classes)
  classes.each { |c| include_class c}
end

def require_models(classes)
  not_entities = ["Queries", "Configurator"]
  entities = classes.map {|c| c.gsub("piql.", "")} - not_entities
  entities.each do |e|
    require "#{RAILS_ROOT}/app/models/#{e.downcase}.rb"
  end
end

include Java

include_class "java.util.jar.JarFile"

PIQL_JAR_PATH = "#{RAILS_ROOT}/db/piql.jar"

require PIQL_JAR_PATH

classes = get_piql_classes

include_piql(classes)
require_models(classes)

$piql_env = Configurator.new.configureTestCluster

include_class "scala.collection.immutable.List"

class Java::ScalaCollectionImmutable::List
  include Enumerable
  def each(&block)
    unless self.isEmpty
      yield self.head
      self.tail.each(&block)
    end
  end
  
  def to_a
    self.collect {|element| element}
  end
end