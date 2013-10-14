module Fluent
    class JsonApiError < StandardError
    end
    class JsonApiInput < Input
        Plugin.register_input('json_api', self)

        config_param :url,      :string,  :default => 'http://pipes.yahoo.com/pipes/pipe.run?_id=c9b9df32b4c3e0ccbe4547ae7e00ed2f&_render=json&condition=d7D&genre=100533&page=__PAGE__'
        config_param :rules   , :string
        config_param :run_interval   , :integer, :default =>  0
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

            begin
                result = []
                (eval config['rules']).each_pair do |key,replecements|
                    combinations = []
                    (replecements.to_a).each do |replacement|
                        combinations << {key => replacement}
                    end 
                    result << combinations
                end

                @rules = result[0].product(*result[1..-1])
            rescue SyntaxError,StandardError => e 
                raise Fluent::ConfigError.new "rules has some errors #{e}"
            end

            raise Fluent::ConfigError unless ['http','https'].include? URI.parse(config['url']).scheme
            @rules.each do |pair|
                url = config['url']
                pair.each do |key_replacements|
                    key_replacements.each do |key,replacement|
                        url = url.gsub(key.to_s,replacement.to_s)
                    end
                end
                @urls.push url
            end
        end

        def start
            super
            @thread = Thread.new(&method(:run))
        end

        def run
            loop {
                @urls.each do |url|
                    Engine.emit @tag, Engine.now , crawl(url)
                    run_interval @run_interval if @run_interval.to_i > 0
                end
            }
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
