/******/ (() => { // webpackBootstrap
/******/ 	var __webpack_modules__ = ({

/***/ "./node_modules/events/events.js":
/*!***************************************!*\
  !*** ./node_modules/events/events.js ***!
  \***************************************/
/***/ ((module) => {

"use strict";
// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.



var R = typeof Reflect === 'object' ? Reflect : null
var ReflectApply = R && typeof R.apply === 'function'
  ? R.apply
  : function ReflectApply(target, receiver, args) {
    return Function.prototype.apply.call(target, receiver, args);
  }

var ReflectOwnKeys
if (R && typeof R.ownKeys === 'function') {
  ReflectOwnKeys = R.ownKeys
} else if (Object.getOwnPropertySymbols) {
  ReflectOwnKeys = function ReflectOwnKeys(target) {
    return Object.getOwnPropertyNames(target)
      .concat(Object.getOwnPropertySymbols(target));
  };
} else {
  ReflectOwnKeys = function ReflectOwnKeys(target) {
    return Object.getOwnPropertyNames(target);
  };
}

function ProcessEmitWarning(warning) {
  if (console && console.warn) console.warn(warning);
}

var NumberIsNaN = Number.isNaN || function NumberIsNaN(value) {
  return value !== value;
}

function EventEmitter() {
  EventEmitter.init.call(this);
}
module.exports = EventEmitter;
module.exports.once = once;

// Backwards-compat with node 0.10.x
EventEmitter.EventEmitter = EventEmitter;

EventEmitter.prototype._events = undefined;
EventEmitter.prototype._eventsCount = 0;
EventEmitter.prototype._maxListeners = undefined;

// By default EventEmitters will print a warning if more than 10 listeners are
// added to it. This is a useful default which helps finding memory leaks.
var defaultMaxListeners = 10;

function checkListener(listener) {
  if (typeof listener !== 'function') {
    throw new TypeError('The "listener" argument must be of type Function. Received type ' + typeof listener);
  }
}

Object.defineProperty(EventEmitter, 'defaultMaxListeners', {
  enumerable: true,
  get: function() {
    return defaultMaxListeners;
  },
  set: function(arg) {
    if (typeof arg !== 'number' || arg < 0 || NumberIsNaN(arg)) {
      throw new RangeError('The value of "defaultMaxListeners" is out of range. It must be a non-negative number. Received ' + arg + '.');
    }
    defaultMaxListeners = arg;
  }
});

EventEmitter.init = function() {

  if (this._events === undefined ||
      this._events === Object.getPrototypeOf(this)._events) {
    this._events = Object.create(null);
    this._eventsCount = 0;
  }

  this._maxListeners = this._maxListeners || undefined;
};

// Obviously not all Emitters should be limited to 10. This function allows
// that to be increased. Set to zero for unlimited.
EventEmitter.prototype.setMaxListeners = function setMaxListeners(n) {
  if (typeof n !== 'number' || n < 0 || NumberIsNaN(n)) {
    throw new RangeError('The value of "n" is out of range. It must be a non-negative number. Received ' + n + '.');
  }
  this._maxListeners = n;
  return this;
};

function _getMaxListeners(that) {
  if (that._maxListeners === undefined)
    return EventEmitter.defaultMaxListeners;
  return that._maxListeners;
}

EventEmitter.prototype.getMaxListeners = function getMaxListeners() {
  return _getMaxListeners(this);
};

EventEmitter.prototype.emit = function emit(type) {
  var args = [];
  for (var i = 1; i < arguments.length; i++) args.push(arguments[i]);
  var doError = (type === 'error');

  var events = this._events;
  if (events !== undefined)
    doError = (doError && events.error === undefined);
  else if (!doError)
    return false;

  // If there is no 'error' event listener then throw.
  if (doError) {
    var er;
    if (args.length > 0)
      er = args[0];
    if (er instanceof Error) {
      // Note: The comments on the `throw` lines are intentional, they show
      // up in Node's output if this results in an unhandled exception.
      throw er; // Unhandled 'error' event
    }
    // At least give some kind of context to the user
    var err = new Error('Unhandled error.' + (er ? ' (' + er.message + ')' : ''));
    err.context = er;
    throw err; // Unhandled 'error' event
  }

  var handler = events[type];

  if (handler === undefined)
    return false;

  if (typeof handler === 'function') {
    ReflectApply(handler, this, args);
  } else {
    var len = handler.length;
    var listeners = arrayClone(handler, len);
    for (var i = 0; i < len; ++i)
      ReflectApply(listeners[i], this, args);
  }

  return true;
};

function _addListener(target, type, listener, prepend) {
  var m;
  var events;
  var existing;

  checkListener(listener);

  events = target._events;
  if (events === undefined) {
    events = target._events = Object.create(null);
    target._eventsCount = 0;
  } else {
    // To avoid recursion in the case that type === "newListener"! Before
    // adding it to the listeners, first emit "newListener".
    if (events.newListener !== undefined) {
      target.emit('newListener', type,
                  listener.listener ? listener.listener : listener);

      // Re-assign `events` because a newListener handler could have caused the
      // this._events to be assigned to a new object
      events = target._events;
    }
    existing = events[type];
  }

  if (existing === undefined) {
    // Optimize the case of one listener. Don't need the extra array object.
    existing = events[type] = listener;
    ++target._eventsCount;
  } else {
    if (typeof existing === 'function') {
      // Adding the second element, need to change to array.
      existing = events[type] =
        prepend ? [listener, existing] : [existing, listener];
      // If we've already got an array, just append.
    } else if (prepend) {
      existing.unshift(listener);
    } else {
      existing.push(listener);
    }

    // Check for listener leak
    m = _getMaxListeners(target);
    if (m > 0 && existing.length > m && !existing.warned) {
      existing.warned = true;
      // No error code for this since it is a Warning
      // eslint-disable-next-line no-restricted-syntax
      var w = new Error('Possible EventEmitter memory leak detected. ' +
                          existing.length + ' ' + String(type) + ' listeners ' +
                          'added. Use emitter.setMaxListeners() to ' +
                          'increase limit');
      w.name = 'MaxListenersExceededWarning';
      w.emitter = target;
      w.type = type;
      w.count = existing.length;
      ProcessEmitWarning(w);
    }
  }

  return target;
}

EventEmitter.prototype.addListener = function addListener(type, listener) {
  return _addListener(this, type, listener, false);
};

EventEmitter.prototype.on = EventEmitter.prototype.addListener;

EventEmitter.prototype.prependListener =
    function prependListener(type, listener) {
      return _addListener(this, type, listener, true);
    };

function onceWrapper() {
  if (!this.fired) {
    this.target.removeListener(this.type, this.wrapFn);
    this.fired = true;
    if (arguments.length === 0)
      return this.listener.call(this.target);
    return this.listener.apply(this.target, arguments);
  }
}

function _onceWrap(target, type, listener) {
  var state = { fired: false, wrapFn: undefined, target: target, type: type, listener: listener };
  var wrapped = onceWrapper.bind(state);
  wrapped.listener = listener;
  state.wrapFn = wrapped;
  return wrapped;
}

EventEmitter.prototype.once = function once(type, listener) {
  checkListener(listener);
  this.on(type, _onceWrap(this, type, listener));
  return this;
};

EventEmitter.prototype.prependOnceListener =
    function prependOnceListener(type, listener) {
      checkListener(listener);
      this.prependListener(type, _onceWrap(this, type, listener));
      return this;
    };

// Emits a 'removeListener' event if and only if the listener was removed.
EventEmitter.prototype.removeListener =
    function removeListener(type, listener) {
      var list, events, position, i, originalListener;

      checkListener(listener);

      events = this._events;
      if (events === undefined)
        return this;

      list = events[type];
      if (list === undefined)
        return this;

      if (list === listener || list.listener === listener) {
        if (--this._eventsCount === 0)
          this._events = Object.create(null);
        else {
          delete events[type];
          if (events.removeListener)
            this.emit('removeListener', type, list.listener || listener);
        }
      } else if (typeof list !== 'function') {
        position = -1;

        for (i = list.length - 1; i >= 0; i--) {
          if (list[i] === listener || list[i].listener === listener) {
            originalListener = list[i].listener;
            position = i;
            break;
          }
        }

        if (position < 0)
          return this;

        if (position === 0)
          list.shift();
        else {
          spliceOne(list, position);
        }

        if (list.length === 1)
          events[type] = list[0];

        if (events.removeListener !== undefined)
          this.emit('removeListener', type, originalListener || listener);
      }

      return this;
    };

EventEmitter.prototype.off = EventEmitter.prototype.removeListener;

EventEmitter.prototype.removeAllListeners =
    function removeAllListeners(type) {
      var listeners, events, i;

      events = this._events;
      if (events === undefined)
        return this;

      // not listening for removeListener, no need to emit
      if (events.removeListener === undefined) {
        if (arguments.length === 0) {
          this._events = Object.create(null);
          this._eventsCount = 0;
        } else if (events[type] !== undefined) {
          if (--this._eventsCount === 0)
            this._events = Object.create(null);
          else
            delete events[type];
        }
        return this;
      }

      // emit removeListener for all listeners on all events
      if (arguments.length === 0) {
        var keys = Object.keys(events);
        var key;
        for (i = 0; i < keys.length; ++i) {
          key = keys[i];
          if (key === 'removeListener') continue;
          this.removeAllListeners(key);
        }
        this.removeAllListeners('removeListener');
        this._events = Object.create(null);
        this._eventsCount = 0;
        return this;
      }

      listeners = events[type];

      if (typeof listeners === 'function') {
        this.removeListener(type, listeners);
      } else if (listeners !== undefined) {
        // LIFO order
        for (i = listeners.length - 1; i >= 0; i--) {
          this.removeListener(type, listeners[i]);
        }
      }

      return this;
    };

function _listeners(target, type, unwrap) {
  var events = target._events;

  if (events === undefined)
    return [];

  var evlistener = events[type];
  if (evlistener === undefined)
    return [];

  if (typeof evlistener === 'function')
    return unwrap ? [evlistener.listener || evlistener] : [evlistener];

  return unwrap ?
    unwrapListeners(evlistener) : arrayClone(evlistener, evlistener.length);
}

EventEmitter.prototype.listeners = function listeners(type) {
  return _listeners(this, type, true);
};

EventEmitter.prototype.rawListeners = function rawListeners(type) {
  return _listeners(this, type, false);
};

EventEmitter.listenerCount = function(emitter, type) {
  if (typeof emitter.listenerCount === 'function') {
    return emitter.listenerCount(type);
  } else {
    return listenerCount.call(emitter, type);
  }
};

EventEmitter.prototype.listenerCount = listenerCount;
function listenerCount(type) {
  var events = this._events;

  if (events !== undefined) {
    var evlistener = events[type];

    if (typeof evlistener === 'function') {
      return 1;
    } else if (evlistener !== undefined) {
      return evlistener.length;
    }
  }

  return 0;
}

EventEmitter.prototype.eventNames = function eventNames() {
  return this._eventsCount > 0 ? ReflectOwnKeys(this._events) : [];
};

function arrayClone(arr, n) {
  var copy = new Array(n);
  for (var i = 0; i < n; ++i)
    copy[i] = arr[i];
  return copy;
}

function spliceOne(list, index) {
  for (; index + 1 < list.length; index++)
    list[index] = list[index + 1];
  list.pop();
}

function unwrapListeners(arr) {
  var ret = new Array(arr.length);
  for (var i = 0; i < ret.length; ++i) {
    ret[i] = arr[i].listener || arr[i];
  }
  return ret;
}

function once(emitter, name) {
  return new Promise(function (resolve, reject) {
    function errorListener(err) {
      emitter.removeListener(name, resolver);
      reject(err);
    }

    function resolver() {
      if (typeof emitter.removeListener === 'function') {
        emitter.removeListener('error', errorListener);
      }
      resolve([].slice.call(arguments));
    };

    eventTargetAgnosticAddListener(emitter, name, resolver, { once: true });
    if (name !== 'error') {
      addErrorHandlerIfEventEmitter(emitter, errorListener, { once: true });
    }
  });
}

function addErrorHandlerIfEventEmitter(emitter, handler, flags) {
  if (typeof emitter.on === 'function') {
    eventTargetAgnosticAddListener(emitter, 'error', handler, flags);
  }
}

function eventTargetAgnosticAddListener(emitter, name, listener, flags) {
  if (typeof emitter.on === 'function') {
    if (flags.once) {
      emitter.once(name, listener);
    } else {
      emitter.on(name, listener);
    }
  } else if (typeof emitter.addEventListener === 'function') {
    // EventTarget does not have `error` event semantics like Node
    // EventEmitters, we do not listen for `error` events here.
    emitter.addEventListener(name, function wrapListener(arg) {
      // IE does not have builtin `{ once: true }` support so we
      // have to do it manually.
      if (flags.once) {
        emitter.removeEventListener(name, wrapListener);
      }
      listener(arg);
    });
  } else {
    throw new TypeError('The "emitter" argument must be of type EventEmitter. Received type ' + typeof emitter);
  }
}


/***/ }),

/***/ "./src/content_scripts/custom-provider.js":
/*!************************************************!*\
  !*** ./src/content_scripts/custom-provider.js ***!
  \************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "CustomProvider": () => (/* binding */ CustomProvider)
/* harmony export */ });
/* harmony import */ var _eth__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../eth */ "./src/eth/index.js");
/* harmony import */ var _eth__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_eth__WEBPACK_IMPORTED_MODULE_0__);

class CustomProvider extends (_eth__WEBPACK_IMPORTED_MODULE_0___default()) {};

/***/ }),

/***/ "./src/content_scripts/event-connection.js":
/*!*************************************************!*\
  !*** ./src/content_scripts/event-connection.js ***!
  \*************************************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "EventConnection": () => (/* binding */ EventConnection)
/* harmony export */ });
const EventEmitter = __webpack_require__(/*! events */ "./node_modules/events/events.js");
class EventConnection extends EventEmitter {
	constructor()
	{
		super();
		this.send = this.offline.bind(this);
		// this.on('', (event) => console.log(`catched event ${event}`));

		//Listening for any window.postMessage
		window.addEventListener('message', messageEvent =>
		{
			console.log(`[Unfiltered] ${JSON.stringify(messageEvent)}`);

			// console.log(messageEvent);
			if(messageEvent ///Checking if the event is not empty
                && messageEvent.source === window ///Checking if the origin is correct
                && messageEvent.data
                && messageEvent.data.type === 'eth:payload' ///Checking if the event is a payload
			){
				console.log(`[Window.addEventListener] ${JSON.stringify(messageEvent)}`,);
				///Emiting for any listeners the request payload of the page
				///Remember: the payload format must be identical to the METAMASK implementation
				this.emit('payload', messageEvent.data.payload);
			}
		});
		if(typeof window.Mobile !== "undefined")
		{
			this.send = this.app.bind(this);
		}
		setTimeout(() => this.emit('connect'), 0);
	}

	offline(payload)
	{
		///Manually adding the origin
		const body = {
			type: 'eth:send',
			payload,
			origin: location.origin
		};
		///Passar esse codigo inteiro para o backend
		const response =
		{
			jsonrpc: '2.0',
			id: payload.id,
		}
		switch(payload.method)
		{
			case "net_version":
				response.result = "43114";
				// this.emit("payload", response);
				this.sendAVME("payload", payload, response);
				console.log(`[emit] ${JSON.stringify(response)}`);
				break;
			case "eth_chainId":
				response.result = "0xa86a";
				// this.emit("payload", response);
				this.sendAVME("payload", payload, response);
				console.log(`[emit] ${JSON.stringify(response)}`);
				break;
			case "eth_requestAccounts":
				response.result = ["0xc7ada9af5c14a058c28cf88b8943a717d706e00b"];
				// this.emit("payload", response);
				this.sendAVME("payload", payload, response);
				console.log(`[emit] ${JSON.stringify(response)}`);
				break;
			case "eth_accounts":
				response.result = ["0xc7ada9af5c14a058c28cf88b8943a717d706e00b"];
				// this.emit("payload", response);
				this.sendAVME("payload", payload, response);
				console.log(`[emit] ${JSON.stringify(response)}`);
				break;
			case "eth_subscribe":
				response.code = -32601;
				response.error = "\"eth_subscribe\" method not found";
				this.sendAVME("eth_subscribe", payload, response);
				break;
			default:
				console.error(`Undefined payload method ${payload.method}`);
				console.error(JSON.stringify(payload));
				break;
		}

		// window.postMessage(body, window.location.origin);
		// console.log(body);
		// this.emit('payload', )
	}

	app(payload)
	{
		const body = {
			type: 'eth:send',
			payload,
			origin: location.origin
		};
		window.Mobile.postMessage(JSON.stringify(body));
		// this.offline(payload);
	}

	sendAVME(event, payload, response)
	{
		this.emit(event, response);
		console.log(JSON.stringify(response));
		try {window.Mobile.postMessage(JSON.stringify(payload));}
		catch(e){}
	}
}

/***/ }),

/***/ "./src/eth/index.js":
/*!**************************!*\
  !*** ./src/eth/index.js ***!
  \**************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

const EventEmitter = __webpack_require__(/*! events */ "./node_modules/events/events.js")

// returns a chainId if it's found to be inconsistent, otherwise false
function updatePayloadChain (payload) {
  if (payload.method === 'eth_sendTransaction') {
    const tx = payload.params[0] || {}
    if ('chainId' in tx) {
      return (parseInt(tx.chainId) !== parseInt(payload.chainId)) && tx.chainId
    }

    tx.chainId = payload.chainId
  }

  return false
}

class EthereumProvider extends EventEmitter {
  constructor (connection) {
    super()

    this.enable = this.enable.bind(this)
    this._send = this._send.bind(this)
    this.send = this.send.bind(this)
    this._sendBatch = this._sendBatch.bind(this)
    this.subscribe = this.subscribe.bind(this)
    this.unsubscribe = this.unsubscribe.bind(this)
    this.sendAsync = this.sendAsync.bind(this)
    this.sendAsyncBatch = this.sendAsyncBatch.bind(this)
    this.isConnected = this.isConnected.bind(this)
    this.close = this.close.bind(this)
    this.request = this.request.bind(this)
    this.connected = false

    this.nextId = 1

    this.promises = {}
    this.subscriptions = []
    this.connection = connection
    this.connection.on('connect', () => this.checkConnection())
    this.connection.on('close', () => {
      this.connected = false
      this.emit('close')
      this.emit('disconnect')
    })
    this.connection.on('', payload => {
        console.info("payload returned");
        console.info(JSON.stringify(payload));
    });
    this.connection.on('payload', payload => {
      const { id, method, error, result } = payload
      if (typeof id !== 'undefined') {
        if (this.promises[id]) { // Fulfill promise
          const requestMethod = this.promises[id].method
          if (requestMethod && ['eth_accounts', 'eth_requestAccounts'].includes(requestMethod)) {
            const accounts = result || []

            this.accounts = accounts
            this.selectedAddress = accounts[0]
            this.coinbase = accounts[0]
          }

          payload.error ? this.promises[id].reject(error) : this.promises[id].resolve(result)
          delete this.promises[id]
        }
      } else if (method && method.indexOf('_subscription') > -1) { // Emit subscription result
        // Events: connect, disconnect, chainChanged, chainsChanged, accountsChanged, assetsChanged, message
        this.emit(payload.params.subscription, payload.params.result)
        this.emit(method, payload.params) // Older EIP-1193
        this.emit('message', { // Latest EIP-1193
          type: payload.method,
          data: {
            subscription: payload.params.subscription,
            result: payload.params.result
          }
        })
        this.emit('data', payload) // Backwards Compatibility
      }
    })

    this.on('newListener', event => {
      if (Object.keys(this.eventHandlers).includes(event)) {
        if (!this._attemptedSubscription(event) && this.connected) {
          this.startSubscription(event)

          if (event === 'networkChanged') {
            console.warn('The networkChanged event is being deprecated, use chainChanged instead')
          }
        }
      }
    })

    this.eventHandlers = {
      networkChanged: netId => {
        this.networkVersion = (typeof netId === 'string') ? parseInt(netId) : netId

        this.emit('networkChanged', this.networkVersion)
      },
      chainChanged: chainId => {
        this.providerChainId = chainId

        if (!this.manualChainId) {
          this.emit('chainChanged', chainId)
        }
      },
      chainsChanged: chains => {
        this.emit('chainsChanged', chains)
      },
      accountsChanged: accounts => {
        this.selectedAddress = accounts[0]
        this.emit('accountsChanged', accounts)
      },
      assetsChanged: assets => {
        this.emit('assetsChanged', assets)
      }
    }
  }

  get chainId () {
    return this.manualChainId || this.providerChainId
  }

  async checkConnection (retry) {
    //   console.log(`checkConnection (${retry})`);
    if (this.checkConnectionRunning || this.connected) return
    this.checkConnectionRunning = true
    try {
        // console.log("[0] try")
      this.networkVersion = await this._send('net_version', [], undefined, false)
      this.providerChainId = await this._send('eth_chainId', [], undefined, false)

      this.checkConnectionRunning = false
      this.connected = true
      this.emit('connect', { chainId: this.providerChainId })

      clearTimeout(this.checkConnectionTimer)

      Object.keys(this.eventHandlers).forEach(event => {
        if (this.listenerCount(event) && !this._attemptedSubscription(event)) this.startSubscription(event)
      })
    } catch (e) {
      if (!retry) setTimeout(() => this.checkConnection(true), 1000)
      this.checkConnectionTimer = setInterval(() => this.checkConnection(true), 4000)
      this.checkConnectionRunning = false
      this.connected = false
    }
  }

  _attemptedSubscription (event) {
    return this[`attempted${event}Subscription`]
  }

  _setSubscriptionAttempted (event) {
    this[`attempted${event}Subscription`] = true
  }

  async startSubscription (event) {
    console.debug(`starting subscription for ${event} events`)

    this._setSubscriptionAttempted(event)

    try {
      const eventId = await this.subscribe('eth_subscribe', event)

      this.on(eventId, this.eventHandlers[event])
    } catch (e) {
      console.warn(`Unable to subscribe to ${event}`, e)
    }
  }

  enable () {
    return new Promise((resolve, reject) => {
      this._send('eth_accounts').then(accounts => {
        if (accounts.length > 0) {
          this.accounts = accounts
          this.selectedAddress = accounts[0]
          this.coinbase = accounts[0]

          this.emit('enable')

          resolve(accounts)
        } else {
          const err = new Error('User Denied Full Provider')
          err.code = 4001
          reject(err)
        }
      }).catch(reject)
    })
  }

  _send (method, params = [], targetChain = this.manualChainId, waitForConnection = true) {
    //   console.log(`_send(${method}, ${params}, ${targetChain}, ${this.manualChainId}, ${waitForConnection})`);
    const sendFn = (resolve, reject) => {
        console.log("sendFn");
      let payload
      if (typeof method === 'object' && method !== null) {
        //   console.log("[0] if");
        payload = method
        payload.params = payload.params || []
        payload.jsonrpc = '2.0'
        payload.id = this.nextId++
      } else {
        payload = { jsonrpc: '2.0', id: this.nextId++, method, params }
      }

      if (!payload.method || typeof payload.method !== 'string') {
        // console.log("[1] if");
        return reject(new Error('Method is not a valid string.'))
      }

      if (targetChain) {
        // console.log("[2] if");
        if (!('chainId' in payload)) payload.chainId = targetChain

        const mismatchedChain = updatePayloadChain(payload)
        if (mismatchedChain) {
          return reject(new Error(`Payload chainId (${mismatchedChain}) inconsistent with specified target chainId: ${targetChain}`))
        }
      }

      this.promises[payload.id] = { resolve, reject, method }
      console.log(`executing this.connection.send(${JSON.stringify(payload)})`);
      this.connection.send(payload)
    }

    if (this.connected || !waitForConnection) {
      return new Promise(sendFn)
    }

    return new Promise((resolve, reject) => {
        console.log("final return of _send");
      const resolveSend = () => {
        clearTimeout(disconnectTimer)
        return resolve(new Promise(sendFn))
      }

      const disconnectTimer = setTimeout(() => {
        this.off('connect', resolveSend)
        reject(new Error('Not connected'))
      }, 5000)

      this.once('connect', resolveSend)
    })
  }

  send (methodOrPayload, callbackOrArgs) { // Send can be clobbered, proxy sendPromise for backwards compatibility
    if (
      typeof methodOrPayload === 'string' &&
      (!callbackOrArgs || Array.isArray(callbackOrArgs))
    ) {
      return this._send(methodOrPayload, callbackOrArgs)
    }

    if (
      methodOrPayload &&
      typeof methodOrPayload === 'object' &&
      typeof callbackOrArgs === 'function'
    ) {
      // a callback was passed to send(), forward everything to sendAsync()
      return this.sendAsync(methodOrPayload, callbackOrArgs)
    }

    return this.request(methodOrPayload)
  }

  _sendBatch (requests) {
    return Promise.all(requests.map(payload => this._send(payload.method, payload.params)))
  }

  subscribe (type, method, params = []) {
    return this._send(type, [method, ...params]).then(id => {
      this.subscriptions.push(id)
      return id
    })
  }

  unsubscribe (type, id) {
    return this._send(type, [id]).then(success => {
      if (success) {
        this.subscriptions = this.subscriptions.filter(_id => _id !== id) // Remove subscription
        this.removeAllListeners(id) // Remove listeners
        return success
      }
    })
  }

  sendAsync (payload, cb) { // Backwards Compatibility
    if (!cb || typeof cb !== 'function') return cb(new Error('Invalid or undefined callback provided to sendAsync'))
    if (!payload) return cb(new Error('Invalid Payload'))
    // sendAsync can be called with an array for batch requests used by web3.js 0.x
    // this is not part of EIP-1193's backwards compatibility but we still want to support it
    payload.jsonrpc = '2.0'

    if (Array.isArray(payload)) {
      return this.sendAsyncBatch(payload, cb)
    } else {
      return this._send(payload.method, payload.params).then(result => {
        cb(null, { id: payload.id, jsonrpc: payload.jsonrpc, result })
      }).catch(err => {
        cb(err)
      })
    }
  }

  sendAsyncBatch (payload, cb) {
    return this._sendBatch(payload).then((results) => {
      const result = results.map((entry, index) => {
        return { id: payload[index].id, jsonrpc: payload[index].jsonrpc, result: entry }
      })
      cb(null, result)
    }).catch(err => {
      cb(err)
    })
  }

  // _sendSync (payload) {
  //   let result

  //   switch (payload.method) {
  //     case 'eth_accounts':
  //       result = this.selectedAddress ? [this.selectedAddress] : []
  //       break

  //     case 'eth_coinbase':
  //       result = this.selectedAddress || null
  //       break

  //     case 'eth_uninstallFilter':
  //       this._send(payload)
  //       result = true

  //     case 'net_version':
  //       result = this.networkVersion || null
  //       break

  //     default:
  //       throw new Error(`unsupported method ${payload.method}`)
  //   }

  //   return {
  //     id: payload.id,
  //     jsonrpc: payload.jsonrpc,
  //     result
  //   }
  // }

  isConnected () { // Backwards Compatibility
    return this.connected
  }

  close () {
    if (this.connection && this.connection.close) this.connection.close()
    this.connected = false
    const error = new Error('Provider closed, subscription lost, please subscribe again.')
    this.subscriptions.forEach(id => this.emit(id, error)) // Send Error objects to any open subscriptions
    this.subscriptions = [] // Clear subscriptions

    this.manualChainId = undefined
    this.providerChainId = undefined
    this.networkVersion = undefined
    this.selectedAddress = undefined
  }

  request (payload) {
    return this._send(payload.method, payload.params, payload.chainId)
  }

  setChain (chainId) {
    if (typeof chainId === 'number') chainId = '0x' + chainId.toString(16)

    const chainChanged = (chainId !== this.chainId)

    this.manualChainId = chainId

    if (chainChanged) {
      this.emit('chainChanged', this.chainId)
    }
  }
}

module.exports = EthereumProvider


/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/************************************************************************/
/******/ 	/* webpack/runtime/compat get default export */
/******/ 	(() => {
/******/ 		// getDefaultExport function for compatibility with non-harmony modules
/******/ 		__webpack_require__.n = (module) => {
/******/ 			var getter = module && module.__esModule ?
/******/ 				() => (module['default']) :
/******/ 				() => (module);
/******/ 			__webpack_require__.d(getter, { a: getter });
/******/ 			return getter;
/******/ 		};
/******/ 	})();
/******/
/******/ 	/* webpack/runtime/define property getters */
/******/ 	(() => {
/******/ 		// define getter functions for harmony exports
/******/ 		__webpack_require__.d = (exports, definition) => {
/******/ 			for(var key in definition) {
/******/ 				if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
/******/ 					Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 				}
/******/ 			}
/******/ 		};
/******/ 	})();
/******/
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	(() => {
/******/ 		__webpack_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ 	})();
/******/
/******/ 	/* webpack/runtime/make namespace object */
/******/ 	(() => {
/******/ 		// define __esModule on exports
/******/ 		__webpack_require__.r = (exports) => {
/******/ 			if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 				Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 			}
/******/ 			Object.defineProperty(exports, '__esModule', { value: true });
/******/ 		};
/******/ 	})();
/******/
/************************************************************************/
var __webpack_exports__ = {};
// This entry need to be wrapped in an IIFE because it need to be in strict mode.
(() => {
"use strict";
/*!**********************!*\
  !*** ./src/index.js ***!
  \**********************/
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _content_scripts_event_connection__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./content_scripts/event-connection */ "./src/content_scripts/event-connection.js");
/* harmony import */ var _content_scripts_custom_provider__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./content_scripts/custom-provider */ "./src/content_scripts/custom-provider.js");



const eventConnection = new _content_scripts_event_connection__WEBPACK_IMPORTED_MODULE_0__.EventConnection();
const provider = new _content_scripts_custom_provider__WEBPACK_IMPORTED_MODULE_1__.CustomProvider(eventConnection);

window.ethereum = provider;
window.ethereum.isMetaMask = true;
window.ethereum.isAVME = true;
window.ethereum.setMaxListeners(0);
})();

/******/ })()
;