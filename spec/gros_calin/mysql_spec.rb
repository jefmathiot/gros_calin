require 'spec_helper'

describe GrosCalin::Mysql do

  it 'registered as mysql' do
    GrosCalin.drivers['mysql'].must_equal subject
  end

  it 'queries the database' do
    Mysql2::Client.expects(:new).with(options={an_option: 1}).
      returns(client=mock)
    client.expects(:query).with('select').
      returns(result=[{ 'id'=>1, 'value'=>BigDecimal.new(0.0075, 2) }])
    subject.new(options).query('id', 'select').
      must_equal [{'id'=>1, 'value'=> 0.0075}]
  end

end
