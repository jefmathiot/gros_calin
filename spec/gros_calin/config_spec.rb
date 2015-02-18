require 'spec_helper'

describe GrosCalin::Collection do

  let(:collection){ subject.new }

  describe 'retrieving items by id' do

    it 'finds the item' do
      collection << mock(id: 1)
      collection << item = mock(id: 2)
      collection.get(2).must_equal item
    end

    it 'ignores items which do not respond to id' do
      collection << mock
      collection << item = mock(id: 2)
      collection.get(2).must_equal item
    end

  end

  it 'includes children when building a serializable hash' do
    collection << mock(json: { id: 1 })
    collection.json.must_equal [{id: 1}]
  end

end

ConfigDriverKlazz = Class.new do
  include GrosCalin::Driver

  register 'driver_id'
end

describe GrosCalin::Datasource do

  let(:datasource){
    GrosCalin::Datasource.new('dsid', ConfigDriverKlazz, {an_option: 1})
  }

  let(:datasource_hash){
    {id: 'dsid', driver: 'driver_id', uri: '/dsid'}
  }

  it 'initializes the driver with options' do
    datasource.driver.must_be_instance_of ConfigDriverKlazz
    datasource.driver.options.must_equal( an_option: 1 )
  end

  it 'creates an empty hugs collection' do
    datasource.hugs.must_be_instance_of GrosCalin::Collection
  end

  it 'builds a serializable hash' do
    datasource.json.must_equal(datasource_hash)
  end


  describe GrosCalin::Hug do

    let(:hug){ subject.new('hugid', datasource, 'select') }

    it 'builds a serializable hash' do
      hug.json.must_equal( id: 'hugid', datasource: datasource_hash,
        uri: '/dsid/hugid' )
    end

    it 'queries the driver' do
      datasource.driver.expects(:query).with('hugid', 'select').
        returns(results=[])
      hug.results.must_equal results
    end

  end

end

describe GrosCalin::Config do

  let(:empty_file) do
    f = Tempfile.new('config.yml')
    f.close
    f
  end

  let(:config_file) do
    f = Tempfile.new('config.yml')
    f.write <<-EOF
---
dsid:
  driver: "driver_id"
  options:
    username: "user"
  hugs:
    all: "select"
EOF
    f.close
    f
  end

  after do
    [config_file, empty_file].each(&:unlink)
  end

  it 'defaults to config.yml' do
    subject.any_instance.expects(:load).with('./config.yml').returns([])
    subject.new
  end

  it 'raises if the config file does not exist' do
    ->{ subject.new('absent.yml')}.must_raise Errno::ENOENT
  end

  it 'raises if the config file does not exist' do
    ex = ->{ subject.new(empty_file)}.must_raise RuntimeError
    ex.message.must_equal "Invalid YAML file #{empty_file}"
  end

  it 'loads the provided configuration' do
    config = subject.new(config_file)
    ds = config.datasources.length.must_equal 1
    ds = config.datasources.first
    ds.id.must_equal 'dsid'
    ds.driver.must_be_instance_of ConfigDriverKlazz
    ds.driver.options['username'].must_equal "user"
    ds.hugs.length.must_equal 1
    hug = ds.hugs.first
    hug.id.must_equal 'all'
    hug.datasource.must_equal ds
    hug.query.must_equal 'select'
  end

end
