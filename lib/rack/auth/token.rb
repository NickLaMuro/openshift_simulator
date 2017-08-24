require 'rack/auth/abstract/handler'
require 'rack/auth/abstract/request'

module Rack
  module Auth
    # Similar implementation to Rack::Auth::Basic, just configured to work with
    # 'Bearer token'.  Probably doesn't follow the RFC properly... can fix that
    # later though..
    class Token < AbstractHandler
      def call(env)
        auth = Token::Request.new(env)

        return unauthorized unless auth.provided?
        return bad_request unless auth.bearer?

        if valid?(auth)
          @app.call(env)
        else
          unauthorized
        end
      end

      private

      def challenge
        "Bearer [TOKEN]"
      end

      def valid?(auth)
        @authenticator.call(auth.token)
      end

      class Request < Auth::AbstractRequest
        def bearer?
          "bearer" == scheme
        end

        def token
          @token ||= params
        end
      end
    end
  end
end
