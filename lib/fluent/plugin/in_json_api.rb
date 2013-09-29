module Fluent
    class JsonApiInput < Input
        Plugin.register_input('json_api', self)

        config_param :url,      :string,  :default => 'http://pipes.yahoo.com/pipes/pipe.run?_id=c9b9df32b4c3e0ccbe4547ae7e00ed2f&_render=json&condition=d7D&genre=100533&page=#page#'
        config_param :max_page, :integer, :default =>  1000
        config_param :tag,      :string

        def initialize
            super
            require 'json'
            require 'net/http'
        end

        def start
            super
            @thread = Thread.new(&method(:run))
        end

        def run
        end

        def shutdown
            Thread.kill(@thread)
        end
    end
end
