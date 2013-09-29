module Fluent
    class JsonApiError < StandardError
    end
    class JsonApiInput < Input
        Plugin.register_input('json_api', self)

        config_param :url,      :string,  :default => 'http://pipes.yahoo.com/pipes/pipe.run?_id=c9b9df32b4c3e0ccbe4547ae7e00ed2f&_render=json&condition=d7D&genre=100533&page=__PAGE__'
        config_param :max_page, :integer, :default =>  1000
        config_param :tag,      :string

        attr_reader :urls
        def initialize
            super
            require 'json'
            require 'net/http'
            @urls = []
        end

        def configure(config)
            super
            raise Fluent::ConfigError unless ['http','https'].include? URI.parse(config['url']).scheme
            for page in 1 .. config['max_page'].to_i
                @urls.push config['url'].gsub('__PAGE__',page.to_s)
            end
        end

        def start
            super
            @thread = Thread.new(&method(:run))
        end

        def run
        end

        def crawl(url)
            response = Net::HTTP.get_response(URI.parse(url))
            case response
            when Net::HTTPSuccess
                return JSON.parse response.body
            end
            raise Fluent::JsonApiError.new
        end

        def shutdown
            Thread.kill(@thread)
        end
    end
end
