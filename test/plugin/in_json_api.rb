require 'fluent/test'
require 'json'
require 'fluent/plugin/in_json_api'

class FileInputTest < Test::Unit::TestCase
    def setup
        Fluent::Test.setup

        @d = create_driver %[
            url   http://pipes.yahoo.com/pipes/pipe.run?_id=c9b9df32b4c3e0ccbe4547ae7e00ed2f&_render=json&condition=d7D&genre=100533&page=__PAGE__
            max_page    10
            tag     input.json
        ]
        @time = Time.now.to_i
    end

    def create_driver(config = CONFIG)
        Fluent::Test::OutputTestDriver.new(Fluent::JsonApiInput).configure(config)
    end

    def test_configure
        assert_equal 'http://pipes.yahoo.com/pipes/pipe.run?_id=c9b9df32b4c3e0ccbe4547ae7e00ed2f&_render=json&condition=d7D&genre=100533&page=__PAGE__'   , @d.instance.url
        assert_equal 10          , @d.instance.max_page
        assert_equal 'input.json', @d.instance.tag
        [ %[
                url   hoge
                max_page    10
                tag     input.json
            ],
          %[
                url   ftp://hoge.com
                max_page    10
                tag     input.json
            ],
          %[
                url   http://hoge.com
                max_page    10
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

    def test_crawls
        for page in 1..1
            url = "http://pipes.yahoo.com/pipes/pipe.run?_id=c9b9df32b4c3e0ccbe4547ae7e00ed2f&_render=json&condition=d7D&genre=100533&page=#{page}"
            response = @d.instance.crawl url
            assert_not_nil response
            assert_equal response['count'], 30
            assert_equal response['value']['items'].size, 30
            response['value']['items'].each do |item|
                #content
                assert item['author']['content'].to_f >= 0.0
                assert item['author']['content'].to_f <= 5.0

                #link
                assert_equal URI.parse(item['link']).scheme, 'http'
                #title
                assert_equal URI.parse(item['title']).scheme, 'http'

                #description
                assert_not_nil item['description']

                #pubDate
                assert_not_nil item['pubDate']['content']
            end
        end
    end
end
