require 'minitest/autorun'
require_relative '../../lib/get_snapshot'

describe GetSnapshot do
  before do
    File.open('./1.json', 'w') do |f|
      f.puts('hello')
    end

    File.open('../../2.json', 'w') do |f|
      f.puts('hello')
    end
  end

  after do
    File.delete('./1.json')
    File.delete('../../2.json')
  end

  describe 'with an existing snapshot' do
    it 'returns its path' do
      GetSnapshot.stub(:base_dir, File.expand_path('.')) do
        path = GetSnapshot.call(1)
        path.must_equal File.expand_path('./1.json')
      end
    end
  end

  describe 'with an non-existing snapshot' do
    it 'returns nil' do
      GetSnapshot.stub(:base_dir, File.expand_path('.')) do
        path = GetSnapshot.call(2)
        assert_nil(path)
      end
    end
  end

  describe 'with a bad path' do
    it 'returns nil' do
      GetSnapshot.stub(:base_dir, File.expand_path('.')) do
        path = GetSnapshot.call('../../2')
        assert_nil(path)
      end
    end
  end
end
