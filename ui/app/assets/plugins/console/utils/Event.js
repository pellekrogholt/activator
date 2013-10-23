/* Dead simple events manager
 * Usage:
 * var evented = Event({
 *   prop: ""
 * })
 * evented.bind("evt", function(e){
 *   console.log(this, e)
 * })
 * evented.trigger("evt", "param")
 */
var Event = function(o){
    o.bind = function(event, fct){
        this._events = this._events || {};
        this._events[event] = this._events[event]  || [];
        this._events[event].push(fct);
    }
    o.unbind = function(event, fct){
        this._events = this._events || {};
        if( event in this._events === false  )  return;
        this._events[event].splice(this._events[event].indexOf(fct), 1);
    }
    o.trigger = function(event /* , args... */){
        this._events = this._events || {};
        if( event in this._events === false  )  return;
        for(var i = 0; i < this._events[event].length; i++){
            this._events[event][i].apply(o, Array.prototype.slice.call(arguments, 1));
        }
    }
    return o;
};
