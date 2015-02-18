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

  describe 'opening a session' do

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

  end

  describe 'querying the database' do

    let(:spec){
      {
        'collection'=>'data',
        'query'=>[
          {
          'find' => {'name'=> 'Bob'} },
          'distinct',
          'ignored' # Not whitelisted
        ]
      }
    }

    def expects_query(result, expected)
      session = expects_session
      session.expects(:[]).with('data').returns(coll=mock)
      coll.expects(:find).with({'name'=>'Bob'}).returns(coll)
      coll.expects(:distinct).returns(result)
      subject.new('database'=>'db').query('spec', spec).must_equal(expected)
    end

    it 'wraps simple values into a hash' do
      expects_query(1, {'spec'=>1})
    end

    it 'uses hash results as is' do
      expects_query({'spec'=>1}, {'spec'=>1})
    end

    it 'converts results to an array' do
      result=mock(to_a: ary = [1, 2])
      expects_query(result, ary)
    end

    it 'raises if mandatory parameters are not present' do
    end

  end

end
