module Doorkeeper
  module OAuth
    module Helpers
      module URIChecker
        def self.valid?(url)
          return true if oob_uri?(url)

          uri = as_uri(url)
          uri.fragment.nil? && !uri.host.nil? && !uri.scheme.nil?
        rescue URI::InvalidURIError
          false
        end

        def self.matches?(url, client_url)
          url = as_uri(url)
          client_url = as_uri(client_url)

          if client_url.query.present?
            return false unless query_matches?(url.query, client_url.query)
            # Clear out queries so rest of URI can be tested. This allows query
            # params to be in the request but order not mattering.
            client_url.query = nil
          end
          url.query = nil
          url == client_url
        end

        def self.valid_for_authorization?(url, client_url)
          valid?(url) && client_url.split.any? { |other_url| matches?(url, other_url) }
        end

        def self.as_uri(url)
          URI.parse(url)
        end

        def self.query_matches?(query, client_query)
          return true if client_query.nil? && query.nil?
          return false if client_query.nil? || query.nil?
          # Will return true independent of query order
          client_query.split('&').sort == query.split('&').sort
        end

        def self.native_uri?(url)
          url == Doorkeeper.configuration.native_redirect_uri
        end

        IETF_WG_OAUTH2_OOB = "urn:ietf:wg:oauth:2.0:oob"
        IETF_WG_OAUTH2_OOB_AUTO = "urn:ietf:wg:oauth:2.0:oob:auto"

        def self.oob_uri?(uri)
          [IETF_WG_OAUTH2_OOB, IETF_WG_OAUTH2_OOB_AUTO].include?(uri)
        end
      end
    end
  end
end
