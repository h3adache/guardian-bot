request = require 'request'
_ = require('lodash')._
Q = require 'q'

class Service
  constructor: (@serviceBase, @headers) ->

  @include: (services) ->
    for service, url of services
      extend = @
      do (service, url) ->
        extend::[service] = (param, params = {}) ->
          template = _.template("#{@serviceBase}/#{url}")
          serviceCall = template(param)
          Service.callApi(serviceCall, params, @headers)

  @callApi: (url, params, headers) ->
    console.log "calling #{url}"
    deferred = Q.defer()
    options = {
      url: url,
      headers: headers,
      qs: params,
      json: true
    };

    request options, (err, req, body) ->
      if err
        deferred.error(err)
      else
        deferred.resolve(Service.unwrapResponse(body))

    return deferred.promise

  @unwrapResponse: (res) ->
    if res.Response && res.Response.data
      return res.Response.data
    else if (res.Response)
      return res.Response
    else
      return res

exports.Service = Service