# This specifies the behavior of the TextAssetResponseCache which controlls the
# caching of stylesheets and javascripts.

require File.dirname(__FILE__) + '/../spec_helper'

describe TextAssetResponseCache do

  class TestResponse < ActionController::TestResponse
    def initialize(body = '', headers = {})
      self.body = body
      self.headers = headers
    end
  end


  before :all do
    @dir = File.expand_path("#{RAILS_ROOT}/test/text_asset_cache")
    @baddir = File.expand_path("#{RAILS_ROOT}/test/bad_text_asset_cache")
    @old_perform_caching = TextAssetResponseCache.defaults[:perform_caching]
    TextAssetResponseCache.defaults[:perform_caching] = true
  end


  before(:each) do
    FileUtils.rm_rf @baddir
    @cache = TextAssetResponseCache.new(
      :directory => @dir,
      :perform_caching => true
    )
    @cache.clear
  end


  after :each do
    FileUtils.rm_rf @dir if File.exists? @dir
  end


  after :all do
    TextAssetResponseCache.defaults[:perform_caching] = @old_preform_caching
  end


  it 'should inherit from the Radiant ResponseCache' do
    @cache.should be_kind_of(ResponseCache)
  end


  it 'should set up its own instance (be independent of the Radiant ResponseCache' do
    @cache.should_not === ResponseCache.instance
  end


  it 'should have its default directory equal to StylesNScripts::Config setting' do
    # change the config setting, re-init the TextAssetResponseCache (a Singleton)
    # and make sure it slurped up the new setting.
    StylesNScripts::Config[:response_cache_directory] = 'foo'
    Singleton.send :__init__, TextAssetResponseCache
    TextAssetResponseCache.instance.defaults[:directory].should == "#{RAILS_ROOT}/foo"

    # reset the config settings, re-init the TextAssetResponseCache (a Singleton)
    # and make sure it aquired the default setting this time.
    StylesNScripts::Config.restore_defaults
    Singleton.send :__init__, TextAssetResponseCache
    TextAssetResponseCache.instance.defaults[:directory].should == "#{RAILS_ROOT}/text_asset_cache"
  end


  it 'should have a default cache expiration of 1 year' do
    @cache.defaults[:expire_time].should == 1.year
  end


# These two specs are stolen directly from the response_cache_spec.  Mostly these
# are redundant tests but I at least wanted to ensure that it actually caches
  ['test/me', '/test/me', 'test/me/', '/test/me/', 'test//me'].each do |url|
    it "should cache response for url: #{url.inspect}" do
      @cache.clear
      response = response('content', 'Last-Modified' => 'Tue, 27 Feb 2007 06:13:43 GMT')
      response.cache_timeout = Time.gm(2007, 2, 8, 17, 37, 9)
      @cache.cache_response(url, response)
      name = "#{@dir}/test/me.yml"
      File.exists?(name).should == true
      file(name).should == "--- \nexpires: 2007-02-08 17:37:09 Z\nheaders: \n  Last-Modified: Tue, 27 Feb 2007 06:13:43 GMT\n" 
      data_name = "#{@dir}/test/me.data"
      file(data_name).should == "content" 
    end
  end


  it 'cache response with extension' do
    @cache.cache_response("styles.css", response('content'))
    File.exists?("#{@dir}/styles.css.yml").should == true
  end

end


private

  def file(filename)
    open(filename) { |f| f.read } rescue ''
  end


  def response(*args)
    TestResponse.new(*args)
  end