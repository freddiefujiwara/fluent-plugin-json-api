require 'fluent/test'
require 'json'
require 'fluent/plugin/in_json_api'

class FileInputTest < Test::Unit::TestCase
    def setup
        Fluent::Test.setup

        @d = create_driver %[
            url    localurl
            max_page    6379
            tag     input.json
        ]
        @time = Time.now.to_i
    end

    def create_driver(config = CONFIG)
        Fluent::Test::OutputTestDriver.new(Fluent::JsonApiInput).configure(config)
    end

    def test_configure
        assert_equal 'localurl'   , @d.instance.url
        assert_equal 6379          , @d.instance.max_page
        assert_equal 'input.json', @d.instance.tag
    end
end
