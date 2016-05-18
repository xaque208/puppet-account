require 'spec_helper'
describe 'account::group' do

  context 'with values for all required parameters' do
    let(:title) { 'humans' }
    let(:params) {{
      :members => [],
      :gid => 2000,
    }}

    it { should contain_group('humans').with_gid(2000) }
    it { should contain_groupmembership('humans').with_members([]) }
  end
end

