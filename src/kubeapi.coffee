class KubeApi
  request = require 'request'
  fs = require 'fs'
  path = require 'path'

  constructor: () ->
    @urlPrefix = 'https://kubernetes.default:443'
    @ca = fs.readFileSync('/var/run/secrets/kubernetes.io/serviceaccount/ca.crt')
    @token = fs.readFileSync('/var/run/secrets/kubernetes.io/serviceaccount/token')

  get: ({path, roles}, callback) ->
    requestOptions =
      url : @urlPrefix + path

    requestOptions['auth'] =
      bearer: @token

    if @ca
      requestOptions.agentOptions =
        ca: @ca

    request.get requestOptions, (err, response, data) ->
      return callback(err) if err
      if response.statusCode == 404
        return callback null, null
      if response.statusCode != 200
        return callback new Error("Error executing request: #{response.statusCode} #{data}")
      if data.startsWith "{"
        callback null, JSON.parse(data)
      else
        callback null, data

  del: ({path, roles}, callback) ->
    requestOptions =
      url : @urlPrefix + path

    requestOptions['auth'] =
      bearer: @token

    if @ca
      requestOptions.agentOptions =
        ca: @ca

    request.del requestOptions, (err, response, data) ->
      return callback(err) if err
      if response.statusCode == 404
        return callback null, null
      if response.statusCode != 200 && response.statusCode != 202
        return callback new Error("Error executing request: #{response.statusCode} #{data}")
      if data.startsWith "{"
        callback null, JSON.parse(data)
      else
        callback null, data

module.exports = KubeApi
