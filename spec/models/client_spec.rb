
require 'rails_helper'

RSpec.describe Client, type: :model do
  let(:client) { create(:client) }
  let!(:opportunity1) { create(:opportunity, client: client) }
  let!(:opportunity2) { create(:opportunity, client: client) }

  describe 'associations' do
    it 'has many opportunities' do
      expect(client.opportunities).to include(opportunity1, opportunity2)
    end

    it 'destroys associated opportunities when the client is destroyed' do
      expect { client.destroy }.to change(Opportunity, :count).by(-2)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(client).to be_valid
    end

    it 'is invalid without a name' do
      client.name = nil
      expect(client).not_to be_valid
    end
  end
end
