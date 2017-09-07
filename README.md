# [READme](http://read-me.herokuapp.com)
## mission

Find me more books to buy.

No, really.

I *definitely* need more books.

You probably need more, too. You should try it.

## usage

* Log in with your Goodreads account.
* Find new books.
* Squeeeeeee.
* Buy said books.

## known issues

* Organization and test structure need work.
    * ~~Move 'helper' methods to models where they belong.~~
    * **Add tests for all those methods!!**

* It's painfully slow.
    * Use Typhoeus to run API requests in parallel.
    * Use ActionCable and Javascript to forward database updates to front end in real-time.

* No support for works with multiple authors.
   * Update database schema to add many-to-many relationship between author and work.

## stretch ideas

* Add ability for user to unfollow an author they're not interested in.
* Add support for works with future release date that's missing some info, such as specific day.
* Add color-coding based on author's average rating to indicate if user will probably enjoy new release.
* Add Amazon purchase links.
* Add support for ordering works by author rather than by date.
* Add ability for user to follow an author they're interested in but may not have read before.
* Add support for tracking series info and recommending the next book in series, even if that book is previously released.
0
