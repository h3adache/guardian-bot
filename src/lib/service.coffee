class Service
  constructor: (@serviceBase, @headers) ->

  @include: (services) ->
    for service, url of services
      extend = @
      do (service, url) ->
        extend::[service] = (param) ->
          Service.callApi("#{@serviceBase}/#{url}", @headers, param)


  @callApi: (url, headers, params) ->
    console.log("calling #{url} with #{params} / headers #{JSON.stringify(headers)}")
#    deferred = new Deferred()
#    options = {
#      url: url,
#      headers: {
#        'X-API-Key': bungie_api_key
#      },
#      qs: params,
#      json : true
#    };
#
#    r options, (err, req, body) ->
#      if body.Response
#        deferred.resolve(body.Response)
#      else
#        deferred.resolve(body)
#
#    return deferred.promise

exports.Service = Service