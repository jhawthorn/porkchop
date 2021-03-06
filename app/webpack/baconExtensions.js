import Bacon from 'baconjs';
import $ from 'jquery';

// FIXME: We have a fetch polyfill and should use it.
Bacon.Observable.prototype.ajax = function() {
  return this.flatMapLatest(
    (params) => Bacon.fromPromise($.ajax(params))
  );
};

Bacon.ajaxPoll = (ajaxOptions, interval) => {
  let requests = new Bacon.Bus();
  let responses = requests.ajax();

  requests.plug(
    Bacon.once(ajaxOptions)
  );

  requests.plug(
    responses.mapError().delay(interval).map(() => ajaxOptions)
  );

  return responses;
};
