class BannersController < ApplicationController
    def banners
    end

    def original_url
        request.original_url
    end

    helper_method :original_url
end
