module OpenshiftSimulator
  class DefaultEndpoint
    ROOT_RESPONSE = [
      200,
      {'Content-Type' => 'text/plain'},
      ["OpenShift Simulator: OK!"]
    ].freeze

    NOT_FOUND_RESPONSE = [
      404,
      {'Content-Type' => 'text/plain'},
      ["OpenShift Simulator: Endpoint Not Found"]
    ].freeze

    def call(env)
      request = Rack::Request.new(env)
      if request.path == "/" && request.request_method == "GET"
        ROOT_RESPONSE
      else
        NOT_FOUND_RESPONSE
      end
    end
  end
end
