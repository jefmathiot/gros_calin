require 'spec_helper'

describe GrosCalin::Driver do

  DriverKlazz = Class.new do
    include GrosCalin::Driver

    register 'test_driver'
  end

  describe DriverKlazz do

    it 'uses the id it registered with' do
      subject.new.id.must_equal 'test_driver'
    end

    it 'exposes its initialization options' do
      subject.new(options={an_option: 1}).options.must_equal options
    end

  end

end
