rp = require 'request-promise'
_ = require('lodash')._
Promise = require('bluebird')

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
    return new Promise (resolve, reject) ->
      options = {
        url: url,
        headers: headers,
        qs: params,
        json: true
      };

      rp(options)
      .then (body) ->
        resolve(Service.unwrapResponse(body))
      .catch (err) ->
        reject(err)

  @unwrapResponse: (body) ->
    response = body.Response?.data ? body.Response ? body
    response.definitions = body.Response?.definitions
    return response

exports.Service = Service