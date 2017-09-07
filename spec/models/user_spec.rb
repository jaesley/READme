require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.create(user_name: 'hayley', uid: '3702636', provider: 'Goodreads', password: 'pw') }

  context '#associations' do
    it { is_expected.to have_many :follows }
    it { is_expected.to have_many :authors }
    it { is_expected.to have_many :books }
  end

  describe '#generate_records' do
    before(:each) do
      reviews = RestClient.get "http://www.goodreads.com/review/list/#{user.uid}?key=#{ENV['GOODREADS_API_KEY']}&sort=author&per_page=5&shelf=read"
      @reviews = Hash.from_xml(reviews.to_s)
      review = @reviews['GoodreadsResponse']['books']['book'][0]
      @author = user.generate_author_hash(review)
    end

    context '#generate_author' do
      it 'is a valid instance of Author' do
        author = user.generate_author(@author)
        expect(author).to be_valid
      end

      it 'saves the author instance to the database' do
        expect{user.generate_author(@author)}.to change(Author, :count).from(0).to(1)
      end
    end

    context '#generate_author_hash' do
      it 'returns a hash' do
        expect(@author).to be_a Hash
      end

      it 'has a name' do
        expect(@author[:name]).to_not be nil
      end

      it 'has a goodreads id' do
        expect(@author[:goodreads_id]).to_not be nil
      end

      it 'has a link to author page' do
        expect(@author[:link]).to_not be nil
      end
    end

    context '#generate_author_hashes' do

      it 'returns an array' do
        data = user.generate_author_hashes(@reviews)
        expect(data).to be_a Array
      end

      it 'stores each author as a hash' do
        data = user.generate_author_hashes(@reviews)
        expect(data).to all be_a Hash
      end
    end

    context '#get_author_single_page' do
      let(:data) { user.get_author_single_page(1) }

      it 'returns a single page from the read shelf as a hash' do
        expect(data).to be_a Hash
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

      it 'aggregates data from each page of a read shelf' do
        pages = [page1, page2, page3, page4, page5, page6]
        total = pages.reduce(0) { |sum, page| sum + page[:author_hashes].length }
        expect(data.length).to eq(total)
      end
    end
  end
end
