require 'spec_helper'

describe GrosCalin::MongoDB do

  it 'registered as mongodb' do
    GrosCalin.drivers['mongodb'].must_equal subject
  end

  def expects_session(hosts=['127.0.0.1:27017'])
    ::Moped::Session.expects(:new).with(hosts).
      returns(session=mock)
    session.expects(:use).with('db')
    session
  end

  def ensure_session_yielded(options={})
    session = nil
    subject.new(options.merge('database'=> 'db')).send(:with_session) do |s|
      session = s
    end
    session.wont_be_nil
  end

  it 'defaults to localhost' do
    expects_session
    ensure_session_yielded
  end

  it 'uses the provided hosts' do
    expects_session( hosts = ['host.tld:27018'] )
    ensure_session_yielded('hosts'=>hosts)
  end

  it 'logs in if a username was provided' do
    session = expects_session ['127.0.0.1:27017']
    session.expects(:login).with('user', 'secret')
    ensure_session_yielded('username'=>'user', 'password'=>'secret')
  end

  it 'queries the database' do
    session = expects_session ['127.0.0.1:27017']
    js = 'db.collection.find().toArray()'
    session.expects(:command).
      with('$eval' => "function(){ return #{js}; }", nolock: true).
        returns({ 'retval'=>ary=[] })
    subject.new({ 'database' => 'db' }).query('id', js).must_equal ary
  end

end
