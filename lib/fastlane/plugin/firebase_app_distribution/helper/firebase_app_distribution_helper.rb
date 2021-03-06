require 'fastlane_core/ui/ui'
require 'cfpropertylist'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    module FirebaseAppDistributionHelper
      def testers_flag(params)
        file_flag_if_supplied("--testers-file", "testers", params)
      end

      def groups_flag(params)
        file_flag_if_supplied("--groups-file", "groups", params)
      end

      def release_notes_flag(params)
        file_flag_if_supplied("--release-notes-file", "release_notes", params)
      end

      def file_flag_if_supplied(flag, param_name, params)
        file = params["#{param_name}_file".to_sym]
        file ||= file_for_contents(param_name.to_sym, params)

        if file
          return "#{flag} #{file}"
        end
      end

      def flag_value_if_supplied(flag, param_name, params)
        "#{flag} #{params[param_name]}" if params[param_name]
      end

      def flag_if_supplied(flag, param_name, params)
        flag if params[param_name]
      end

      ##
      # always return a file for a given content
      def file_for_contents(parameter_name, params)
        if @tempfiles.nil?
          @tempfiles = []
        end

        contents = params[parameter_name]
        return nil if contents.nil?

        file = Tempfile.new(parameter_name.to_s)
        file.write(contents)
        file.close
        @tempfiles << file

        file.path
      end

      def cleanup_tempfiles
        return if @tempfiles.nil?
        @tempfiles.each(&:unlink)
      end

      def parse_plist(path)
        CFPropertyList.native_types(CFPropertyList::List.new(:file => path).value)
      end
      def findout_ios_app_id_from_archive(path)
        appPath = parse_plist("#{path}/Info.plist")["ApplicationProperties"]["ApplicationPath"]
        UI.shell_error! "can't extract application path from Info.plist at #{path}" if appPath.empty?
        identifier = parse_plist("#{path}/Products/#{appPath}/GoogleService-Info.plist")["GOOGLE_APP_ID"]
        UI.shell_error! "can't extract GOOGLE_APP_ID" if identifier.empty?
        return identifier
      end
    end
  end
end
