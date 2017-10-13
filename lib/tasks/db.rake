namespace :db do
  desc "Clear outdated works from the database each day"
  task :update => :environment do
    books = Books.all.select { |book| book.publication_date  < Date.today }
    books.each { |book| book.destroy }
    end
  end
end
