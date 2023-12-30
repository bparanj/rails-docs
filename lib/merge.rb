require "erb"

# Build template data class.
class Product
    def initialize( code, name, desc, cost )
        @code = code
        @name = name
        @desc = desc
        @cost = cost

        @features = [ ]
    end

    def add_feature( feature )
        @features << feature
    end

    # Support templating of member data.
    def get_binding
        binding
    end

    # ...
end

# Create template.
template = File.read("./lib/template.html.erb")

erb = ERB.new(template)

# Set up template data.
toy = Product.new( "TZ-1002",
                   "Ruby Are Forever",
                   "Responds to Ruby commands...",
                    999.95 )
toy.add_feature("Listens for verbal commands in the Ruby language!")
toy.add_feature("Ignores Perl, Java, and all C variants.")
toy.add_feature("Karate-Chop Action!!!")
toy.add_feature("Matz signature on left leg.")
toy.add_feature("Gem studded eyes... Rubies, of course!")

# Produce result.
result = erb.result(toy.get_binding)

puts result
# Save result to file.
File.write("out.html", result)
