#
# Copyright (C) 2010 Jez Cope
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

require 'rubygems'
require 'savon'
require 'nokogiri'

module Sakai
  module WebServices

    SERVICE_DEFAULTS = {
      :server   => 'localhost',
      :port     => nil,
      :ssl      => true
    }

    class Service
      def initialize(args)
        args = SERVICE_DEFAULTS.merge(args)

        @endpoint =
          "http%s://%s%s/sakai-axis/%s.jws" % [
            args[:ssl] ? 's' : '',
            args[:server],
            args[:port] ? ":#{args[:port]}" : '',
            args[:service]
          ]

        @client = Savon::Client.new
        @client.wsdl.endpoint = @endpoint
        @client.wsdl.namespace = @endpoint
      end

      # Register a SOAP method for a service
      #
      # @param [Symbol] name the name of the method in snake_case.
      # @param [Block] block an optional block to process the method result into
      #       something more useful
      def self.soap_method(name, &block)
        define_method name do |params|
          # method = (name.to_s + '!').to_sym

          response = @client.request(name) do |soap|
            soap.body = params
          end

          response_key = "#{name}_response".to_sym
          return_key = "#{name}_return".to_sym
          response = response[response_key][return_key]

          match = response =~ /((?:\w+\.)*(?:\w+Exception)) : (.*)/

          raise $1 if match

          if block
            return self.instance_exec(response, &block)
          else
            return response
          end
        end
      end

      protected

      def extract_list_from_xml(xml_str, item_name = 'item')
        list = []

        doc = Nokogiri::XML(xml_str)
        doc.xpath("/list/#{item_name}").each do |item|
          x = {}
          item.children.each do |attrib|
            x[attrib.name.snakecase.to_sym] = attrib.content
          end
          list << x
        end

        return list
      end

    end

    class Login < Service
      def initialize(args = {})
        super(args.merge(:service => 'SakaiLogin'))
      end

      soap_method :login
      soap_method :logout

      def session(id, password)
        session_id = self.login(:id => id, :pw => password)
        yield session_id
        self.logout(:id => session_id)
      end
    end

    class Script < Service
      def initialize(args = {})
        super(args.merge(:service => 'SakaiScript'))
      end

      soap_method :get_all_users do |response|
        extract_list_from_xml(response)
      end

      soap_method :get_sites_user_can_access do |response|
        extract_list_from_xml(response)
      end

      soap_method :copy_role

      soap_method :set_role_for_authz_group_maintenance

      soap_method :check_for_user_in_authz_group

      soap_method :add_member_to_authz_group_with_role

      soap_method :remove_role_from_authz_group

      soap_method :get_users_in_authz_group_with_role do |response|
        extract_list_from_xml(response, 'user')
      end

      soap_method :get_all_users
      soap_method :get_user_id
      
      soap_method :get_site_title

      soap_method :get_site_description
      soap_method :change_site_description

      soap_method :copy_site
    end
  end
end
