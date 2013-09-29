require 'fluent/test'
require 'json'
require 'fluent/plugin/in_json_api'

class FileInputTest < Test::Unit::TestCase
    def setup
        Fluent::Test.setup

        @d = create_driver %[
            url   http://pipes.yahoo.com/pipes/pipe.run?_id=c9b9df32b4c3e0ccbe4547ae7e00ed2f&_render=json&condition=d7D&genre=100533&page=__PAGE__
            max_page    1000
            tag     input.json
        ]
        @time = Time.now.to_i
    end

    def create_driver(config = CONFIG)
        Fluent::Test::OutputTestDriver.new(Fluent::JsonApiInput).configure(config)
    end

    def test_configure
        assert_equal 'http://pipes.yahoo.com/pipes/pipe.run?_id=c9b9df32b4c3e0ccbe4547ae7e00ed2f&_render=json&condition=d7D&genre=100533&page=__PAGE__'   , @d.instance.url
        assert_equal 1000          , @d.instance.max_page
        assert_equal 'input.json', @d.instance.tag
        [ %[
                url   hoge
                max_page    1000
                tag     input.json
            ],
          %[
                url   ftp://hoge.com
                max_page    1000
                tag     input.json
            ],
          %[
                url   http://hoge.com
                max_page    1000
            ],
          %[
                url   http://hoge.com
                max_page    hoge
            ]
        ].each do |config|
            assert_raise Fluent::ConfigError do
                create_driver config
            end
        end
    end
    def test_urls
        page = 1
        @d.instance.urls.each do |url|
            assert_equal "http://pipes.yahoo.com/pipes/pipe.run?_id=c9b9df32b4c3e0ccbe4547ae7e00ed2f&_render=json&condition=d7D&genre=100533&page=#{page}", url
            page += 1
        end
    end
end
