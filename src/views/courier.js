var _ = require("underscore");

var delegateEventSplitter = /^(\S+)\s*(.*)$/;
var lastPossibleViewElement = _.isFunction( $ ) ? $( "body" )[ 0 ] : null;


Courier = {};

Courier.add = function( view ) {
  var overriddenViewMethods = {
    setElement : view.setElement
  };

  // ****************** Public Courier functions ****************** 

  view.spawn = function( message, data ) {
    // can be called with message argument as an object, in which case message.name is required,
    // or can be called with message as a string that represents the name of the message and
    // data object which will be added to message object at message.data
    if( _.isString( message ) )
      message = {
        name : message,
        data : _.extend( {}, data )
      };
    else if( _.isUndefined( message.name ) ) throw new Error( "Undefined message name." );

    message.source = view;
    message.data = message.data || {};

    this.trigger( message.name, message.data );

    var isRoundTripMessage = message.name[ message.name.length - 1 ] === "!";

    var curParent = this._getParentView();
    var messageShouldBePassed;
    var value;

    while( curParent ) {
      // check to see if curParent has an action to perform when this message is received.
      if( _.isObject( curParent.onMessages ) ) {
        value = getValueOfBestMatchingHashEntry( curParent.onMessages, message, curParent );
        if( value !== null ) {
          var method = value;
          if( ! _.isFunction( method ) ) method = curParent[ value ];
          if( ! method ) throw new Error( "Method \"" + value + "\" does not exist" );

          var returnValue = method.call( curParent, message );
          if( isRoundTripMessage ) return returnValue;
        }
      }

      messageShouldBePassed = false;

      // execute `passMessages` if its configured as a function
      var passMessages = _.result( curParent, "passMessages" );
      // check to see if this message should be passed up a level
      if( _.isObject( passMessages ) ) {
        value = getValueOfBestMatchingHashEntry( passMessages, message, curParent );
        if( value !== null ) {
          if( value === "." )
            ; // noop - pass this message through exactly as-is
          else if( _.isString( value ) ) {
            // if value is a string, we pass the existing message but
            // change the name to the supplied string
            message.name = value;
          }
          else if( _.isFunction( value ) ) {
            // if value is a function, we call the function after clearing the
            // message data, in order that it may modify the message as it sees
            // fit (adding new data, changing the name), and then pass the message
            var oldMessageData = message.data;
            message.data = {};
            value.call( curParent, message, oldMessageData );
          }
          else throw new TypeError( "Values of passMessages hash should be strings or functions." );

          messageShouldBePassed = true;
        }
        else if( isRoundTripMessage ) messageShouldBePassed = true; // round trip messages are passed up even if there is not an entry in the passMessages hash
      }

      if( isRoundTripMessage ) messageShouldBePassed = true; // round trip messages are passed up even if there is not an entry in the passMessages hash

      if( ! messageShouldBePassed ) break; // if this message should not be passed, then we are done

      message.source = curParent; // keep the source of the message current as the message bubbles up the view hierarchy
      curParent = curParent._getParentView();
    }

    if( isRoundTripMessage )
      throw new Error( "Round trip message \"" + message.name + "\" was not handled. All round trip messages must be handled." );
  };

  // supply your own _getParentView function on your view objects
  // if you would like to use custom means to determine a view's
  // "parent". The default means is to traverse the DOM tree and return
  // the closest parent element that has a view object attached in el.data( "view" )
  if( ! _.isFunction( view._getParentView ) )
    view._getParentView = function() {
      var parent = null;
      var curElement = this.$el.parent();
      while( curElement.length > 0 && curElement[0] !== lastPossibleViewElement ) {
        var view = curElement.data( "view" );
        if( view && view instanceof Backbone.View ) {
          parent = view;
          break;
        }

        curElement = curElement.parent();
      }

      return parent;
    };

  // supply your own _getChildViewNamed function on your view objects
  // if you would like to use another means to test the source of your
  // messages (used for keys of onMessages and passMessages of the form
  // { "message source" : handler }). By default, child views are looked
  // up by name in view.subviews[ childViewName ] (and then tested against message.source)
  if( ! _.isFunction( view._getChildViewNamed ) )
    view._getChildViewNamed = function( childViewName ) {
      if( ! _.isObject( this.subviews ) ) return null;
      return this.subviews[ childViewName ];
    };

  // ****************** Overridden Backbone.View functions ****************** 

  view.setElement = function( element, delegate ) {
    var retval = overriddenViewMethods.setElement.call( this, element, delegate );
    prepareViewElement( view );
    return retval;
  };

  // ****************** Body of Backbone.Courier.add() function ****************** 

  if( view.$el ) prepareViewElement( view ); // otherwise this will be done when #setElement is called

  // ****************** Private Utility Functions ****************** 

  function prepareViewElement( view ) {
    // store a reference to the view object in the DOM element's jQuery data. Make sure it is supported.
    if( _.isFunction( view.$el.data ) && ! view.$el.data( "view" ) ) view.$el.data( "view", view );
  }

  function getValueOfBestMatchingHashEntry( hash, message, view ) {
    // return the value of the entry in a onMessages or passMessages hash that is the 
    // "most specific" match for this message, or null, if there are no matches.

    var matchingEntries = [];

    for( var key in hash ) {
      // We are looking for keys in the hash that have the `message` argument
      // as the first word of their key. If we find one, they either need
      // no source qualifier as the second word of the key (in which case
      // we will pass this message regardless of where it comes from),
      // or we need this the name of the subview that is the source of the
      // message second word of the key.

      var match = key.match( delegateEventSplitter );

      var eventName = match[ 1 ], subviewName = match[ 2 ];
      var eventNameRegEx = new RegExp( eventName.replace( "*", "[\\w]*" ) );
      if( ! eventNameRegEx.test( message.name ) ) continue;

      if( subviewName !== "" && view._getChildViewNamed( subviewName ) !== message.source ) continue;

      matchingEntries.push( { eventName : eventName, subviewName : subviewName, value : hash[ key ] } );
    }

    // if more than one hash keys match, order them by specificity, that is,
    // in descending order of how many non-wild card characters they contain,
    // so that entry with most specificity is at index 0. Also, consider any
    // entries that have subview qualifier more specific than those that do not.
    if( matchingEntries.length > 1 )
      matchingEntries = _.sortBy( matchingEntries, function( thisEntry ) {
        var nonWildcardCharactersInEventName = thisEntry.eventName.replace( "*", "" );
        var hasSubviewQualifier = thisEntry.subviewName !== "";

        // promote all entries with subview qualifiers to a higher level of specificity.
        // Figure there will never, ever be a 1000 character long event name
        var specificity = ( hasSubviewQualifier ? 1000 : 0 ) + nonWildcardCharactersInEventName.length;

        // negate to sort in descending order
        return( - specificity );
      } );

    return matchingEntries.length ? matchingEntries[ 0 ].value : null;
  }
};

module.exports = Courier;
