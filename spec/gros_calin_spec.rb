require 'spec_helper'
require 'rack/test'

describe GrosCalin::Application do
  include Rack::Test::Methods

  let(:config){ mock }
  let(:data){ { key: 'value' } }
  let(:body){ '{"key":"value"}' }

  def app
    subject.set :config, config
    subject
  end

  it 'renders the error message on error' do
    config.expects(:datasources).raises(RuntimeError, "That's an error")
    get '/'
    last_response.status.must_equal 500
    last_response.body.must_equal "Something went wrong: That's an error"
  end

  it 'lists datasources' do
    config.expects(:datasources).returns(mock(json: data))
    get '/'
    last_response.status.must_equal 200
    last_response.body.must_equal body
  end

  def datasources
    config.expects(:datasources).returns(datasources=mock)
    datasources
  end

  def expects_404(collection, param, url, error_message)
    collection.expects(:get).with(param).returns(nil)
    get url
    last_response.status.must_equal 404
    last_response.body.must_match error_message
  end

  it 'renders a 404 when it fails to find a specific datasource' do
    expects_404(datasources, 'dsid', '/dsid', /^Unknown datasource/)
  end

  describe 'with a specific datasource' do

    let(:datasource){ mock }

    before do
      datasources.expects(:get).with('dsid').returns(datasource)
    end

    def ensure_json_array
      last_response.status.must_equal 200
      last_response.body.must_equal "[#{body}]"
    end

    it 'shows the list of hugs for a datasource' do
      datasource.expects(:hugs).returns([mock(json: data)])
      get '/dsid'
      ensure_json_array
    end

    def hugs
      datasource.expects(:hugs).returns(hugs=mock)
      hugs
    end

    it 'renders a specific hug' do
      hugs.expects(:get).with('hugid').returns(mock(results: [data]))
      get '/dsid/hugid'
      ensure_json_array
    end

    it 'renders a 404 when it fails to find a specific hug' do
      expects_404(hugs, 'hugid', '/dsid/hugid', /^Unknown hug/)
    end

  end

end
