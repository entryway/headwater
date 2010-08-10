require 'machinist/mongoid'

Project.send :include, Machinist::Mongoid::Machinable


Project.blueprint do
  name { "Chunky Bacon Project" }
end

# Add your blueprints here.
#
# e.g.
#   Post.blueprint do
#     title { "Post #{sn}" }
#     body  { "Lorem ipsum..." }
#   end
