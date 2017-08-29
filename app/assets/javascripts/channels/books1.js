this.App = {};

App.cable = ActionCable.createConsumer('/cable');

App.messages = App.cable.subscriptions.create('BooksChannel', {
  received: function(data) {
    // $("#releases").removeClass('hidden')
    return console.log(data)
    // return $('#releases').append(this.renderBook(data));
  },

  renderBook: function(data) {
    return "<p> <b>" + data.author + ": </b>" + data.title + "</p>";
  }
});
