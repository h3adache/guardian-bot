request = require 'request'
_ = require('lodash')._
Q = require 'q'

class Service
  constructor: (@serviceBase, @headers) ->

  @include: (services) ->
    for service, url of services
      extend = @
      do (service, url) ->
        extend::[service] = (param) ->
          template = _.template("#{@serviceBase}/#{url}")
          serviceCall = template(param)
          Service.callApi(serviceCall, @headers)

  @callApi: (url, headers) ->
    console.log "calling #{url}"
    deferred = Q.defer()
    options = {
      url: url,
      headers: headers,
      json: true
    };

    request options, (err, req, body) ->
      if err
        deferred.error(err)
      else
        deferred.resolve(Service.unwrapDestinyResponse(body))

    return deferred.promise

  @unwrapDestinyResponse: (res) ->
    if res.Response && res.Response.data
      return res.Response.data
    else if (res.Response)
      return res.Response
    else
      return res

exports.Service = Service