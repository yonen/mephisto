require File.dirname(__FILE__) + '/../test_helper'

context "Site" do
  fixtures :sites, :contents

  specify "should create site without accepting comments" do
    site = Site.new :host => 'foo.com', :comment_age => -1
    assert_valid site
    assert !site.accept_comments?
    assert !site.approve_comments?
  end

  specify "should create site with approving comments" do
    site = Site.new :host => 'foo.com', :approve_comments => true
    assert_valid site
    assert site.accept_comments?
    assert site.approve_comments?
  end

  specify "should find valid articles" do
    assert_equal contents(:welcome), sites(:first).articles.find(:first, :order => 'contents.id')
    assert_equal contents(:cupcake_welcome), sites(:hostess).articles.find(:first, :order => 'contents.id')
  end
  
  specify "should find by host" do
    assert_equal sites(:first), Site.find_by_host('test.com')
    assert_equal sites(:hostess), Site.find_by_host('cupcake.com')
  end

  specify "should allow empty filter" do
    sites(:first).update_attribute :filter, ''
    assert_equal '', sites(:first).reload.filter
  end
  
  specify "should generate search url" do
    assert_equal '/search?q=abc',        sites(:first).search_url('abc')
    assert_equal '/search?q=abc&page=2', sites(:first).search_url('abc', 2)
  end
end

context "Default Site Options" do
  def setup
    @site = Site.new :host => 'foo.com'
    assert_valid @site
  end

  specify "should accept comments by default" do
    assert @site.accept_comments?
  end

  specify "should not approve comments by default" do
    assert !@site.approve_comments?
  end
  
  specify "should preset search path" do
    assert_equal 'search', @site.search_path
  end
  
  specify "should preset tag path" do
    assert_equal 'tags', @site.tag_path
  end
  
  specify "should set permalink" do
    assert_equal ':year/:month/:day/:permalink', @site.permalink_style
  end
end

context "Site Validations" do
  fixtures :sites

  def setup
    @site = Site.new :host => 'foo.com'
    assert_valid @site
  end

  specify "should validate unique host" do
    assert_valid sites(:first)
    assert_no_difference Site, :count do
      assert Site.create(:host => sites(:first).host.upcase, :title => 'Copy').new_record?
    end
  end

  specify "should require valid host name format" do
    s = Site.new
    ['foo', '-34.com', 'A!'].each do |host|
      s.host = host
      s.valid?
      assert s.errors.on(:host), "host valid with #{host}"
    end
  end
  
  specify "should require valid search path" do
    @site.search_path = '/foo/bar'
    assert !@site.valid?
    assert @site.errors.on(:search_path)
  end
  
  specify "should downcase search path" do
    @site.search_path = "SEARCHES"
    assert_valid @site
    assert_equal 'searches', @site.search_path
  end
  
  specify "should require valid tag path" do
    @site.tag_path = '/foo/bar'
    assert !@site.valid?
    assert @site.errors.on(:tag_path)
  end
  
  specify "should downcase tag path" do
    @site.tag_path = "TAGGING"
    assert_valid @site
    assert_equal 'tagging', @site.tag_path
  end
  
  specify "should downcase permalink style" do
    @site.permalink_style = 'ARTICLE/:ID'
    assert_valid @site
    assert_equal 'article/:id', @site.permalink_style
  end
end