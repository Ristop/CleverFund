module GmailReader
    require 'google/apis/gmail_v1'
    require 'googleauth'
    require 'googleauth/stores/file_token_store'

    require 'fileutils'
    require 'notice_parser.rb'
    require 'date'

    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    APPLICATION_NAME = 'CleverFund'.freeze
    CLIENT_SECRETS_PATH = 'C:/Users/Risto/Dropbox/Programmeerimine/CleverFund/lib/client_secret.json'.freeze
    CREDENTIALS_PATH = File.join(Dir.home, '.credentials', 'gmail-ruby-quickstart.yaml')
    SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

    # Added these two lines to get over the cert error
    cert_path = Gem.loaded_specs['google-api-client'].full_gem_path + '/lib/cacerts.pem'
    ENV['SSL_CERT_FILE'] = cert_path

    ##
    # Ensure valid credentials, either by restoring from the saved credentials
    # files or intitiating an OAuth2 authorization. If authorization is required,
    # the user's default browser will be launched to approve the request.
    #
    # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
    def self.authorize
        FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

        client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
        token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
        authorizer = Google::Auth::UserAuthorizer.new(
            client_id, SCOPE, token_store
        )
        user_id = 'default'
        credentials = authorizer.get_credentials(user_id)
        if credentials.nil?
            url = authorizer.get_authorization_url(
                base_url: OOB_URI
            )
            puts 'Open the following URL in the browser and enter the ' \
                 'resulting code after authorization'
            puts url
            code = gets
            credentials = authorizer.get_and_store_credentials_from_code(
                user_id: user_id, code: code, base_url: OOB_URI
            )
        end
        credentials
    end

    @@authorization = authorize

    def self.read_bank_notices(date)
        # Initialize the API
        service = Google::Apis::GmailV1::GmailService.new
        service.client_options.application_name = APPLICATION_NAME
        service.authorization = @@authorization

        google_formated_date = DateTime.strptime(date, '%s').to_formatted_s(:google_after)

        user_id = 'me' # Use authenicated users email
        all_messages = service.list_user_messages(user_id, q: 'from:automailer@seb.ee after:' + google_formated_date, max_results: 15, include_spam_trash: false)

        newest_date = nil

        all_messages.messages.each do |message|
            message = service.get_user_message(user_id, message.id)
            message_internal_date = message.internal_date[0..-4]

            next unless DateTime.strptime(message_internal_date, '%s') > DateTime.strptime(date, '%s')
            if newest_date.nil? || DateTime.strptime(newest_date, '%s') < DateTime.strptime(message_internal_date, '%s')
                puts 'Updating date'
                newest_date = message_internal_date
            end
            message_body = message.payload.parts[0].body.data.force_encoding('UTF-8')

            # Figure out what type of message it is
            if message_body.include? 'Teie kontol on toimunud broneering'
                NoticeParser.parseBroneering(message_body, message_internal_date)
            elsif message_body.include? "Teie kontolt on toimunud väljaminek"
                NoticeParser.parseValjaminek(message_body, message_internal_date)
            elsif message_body.include? 'Teie kontole on toimunud laekumine'
                NoticeParser.parseLaekmine(message_body, message_internal_date)
            else
                raise "Exception - Unknow notice type! - #{message_body}"
			end

        end
        unless newest_date.nil?
            puts 'Writing new date'
            AppVariable.find(1).update_attribute(:value, newest_date)
        end
    end
end
