const {TextEncoder, TextDecoder} = require('util');

// Polyfill TextEncoder and TextDecoder if they are not defined globally.
if (typeof global.TextEncoder === 'undefined') {
  global.TextEncoder = TextEncoder;
}
if (typeof global.TextDecoder === 'undefined') {
  global.TextDecoder = TextDecoder;
}

