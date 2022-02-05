# Description:
#   Lets you interact with kubernetes
#
# Commands:
#   hubot k8s context - Diplay current Kubernetes context
#   hubot k8s context <context> - Change Kubernetes context
#   hubot k8s namespace - Diplay current Kubernetes namespace
#   hubot k8s namespace <namespace> - Change Kubernetes namespace
#   hubot k8s deployments - List Kubernetes deployments in current namespace
#   hubot k8s pods - List Kubernetes pods in current namespace
#   hubot k8s services - List Kubernetes services in current namespace
#   hubot k8s cronjobs - List Kubernetes cronjobs in current namespace
#   hubot k8s jobs - List Kubernetes jobs in current namespace
#   hubot k8s logs <pod name> - Return log of the named pod in current namespace

Config = require "./config"
KubeApi = require "./kubeapi"

module.exports = (@robot) ->
  # get/set kubernetes namespaces
  robot.respond /k8s\s*(namespace|ns)\s*(.+)?/i, (res) ->
    namespace = res.match[2]
    if not namespace or namespace is ""
      return res.reply "Your current kubernetes namespace is: `#{Config.getNamespace(res)}`"
    Config.setNamespace res, namespace
    res.reply "Your current kubernetes namespace is changed to `#{namespace}`"

  robot.respond /k8s\s*(deployments|deploy|statefulsets|sts|pods|po|services|svc|cronjobs|jobs)\s*(.+)?/i, (res) ->
    namespace = Config.getNamespace(res)
    resource = res.match[1]
    if alias = Config.resourceAliases[resource] then resource = alias
    apiPrefix = Config.resourceApiPrefix[resource] || "/api/v1";

    url = "#{apiPrefix}/namespaces/#{namespace}/#{resource}"
    if res.match[2] and res.match[2] != ""
      url += "?labelSelector=#{res.match[2].trim()}"

    kubeapi = new KubeApi()
    kubeapi.get {path: url}, (err, response) ->
      if err
        robot.logger.error err
        return res.send "Could not fetch *#{resource}* in namespace *#{namespace}*"
      return res.reply "Requested resource *#{resource}* with labelSelector *#{res.match[2]}* not found in namespace *#{namespace}*" unless response and response.items and response.items.length
      responseFormat = Config.responses[resource] or ->
      reply = "Here is the list of *#{resource}* running in namespace *#{namespace}*\n"
      reply += responseFormat(response, process.env.HUBOT_K8S_CONSOLE)
      res.reply reply

  robot.respond /k8s\s*(logs|log)\s*(.+)?/i, (res) ->
    namespace = Config.getNamespace(res)
    pod = res.match[2]

    url = "/api/v1/namespaces/#{namespace}/pods/#{pod}/log"
    kubeapi = new KubeApi()
    kubeapi.get {path: url}, (err, response) ->
      if err
        robot.logger.error err
        return res.send "Could not fetch logs for pod *#{pod}* in namespace *#{namespace}*"
      return res.reply "Requested *logs* not found for pod *#{pod}* in namespace *#{namespace}*" unless response
      reply = "Here are latest logs from pod *#{pod}* in namespace *#{namespace}*\n"
      reply += "```#{response}```\n"

      res.reply reply
