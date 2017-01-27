require 'spec_helper'
describe 'account::group' do
  context 'with values for all required parameters' do
    let(:title) { 'humans' }
    let(:params) do
      {
        members: [],
        gid: 2000
      }
    end

    it { is_expected.to contain_group('humans').with_gid(2000) }
    it { is_expected.to contain_groupmembership('humans').with_members([]) }
  end
end
