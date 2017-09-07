require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.create(user_name: 'hayley', uid: '3702636', provider: 'Goodreads', password: 'pw') }

  context '#associations' do
    it { is_expected.to have_many :follows }
    it { is_expected.to have_many :authors }
    it { is_expected.to have_many :books }
  end

  describe '#generate_records' do
    context '#get_author_single_page'
      let(:data) { user.get_author_single_page(1) }

      it 'returns a single page from the read shelf as a hash' do
        expect(data).to be_a Hash
      end

      it 'includes an array of authors' do
        expect(data[:author_hashes]).to be_a Array
      end

      it 'stores each author as a hash' do
        expect(data[:author_hashes]).to all be_a Hash
      end

      it 'returns the total number of reviews as an integer' do
        expect(data[:total]).to be_a Integer
      end
  end

  context '#get_author_all_pages' do
    let(:data) { user.get_author_all_pages }
    let(:page1) { user.get_author_single_page(1) }
    let(:page2) { user.get_author_single_page(2) }
    let(:page3) { user.get_author_single_page(3) }
    let(:page4) { user.get_author_single_page(4) }
    let(:page5) { user.get_author_single_page(5) }
    let(:page6) { user.get_author_single_page(6) }

    it 'returns an array' do
      expect(data).to be_a Array
    end

    it 'stores each item as a hash' do
      expect(data).to all be_a Hash
    end

    it 'aggregates data from each page of a read shelf' do
      total = 0
      pages = [page1, page2, page3, page4, page5, page6]
      pages.each { |page| total += page[:author_hashes].length }
      expect(data.length).to eq(total)
    end
  end
end
