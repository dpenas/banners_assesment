class CampaignsController < ApplicationController

    def getBanner()
        return Banner.execute(params, session)
    end

    helper_method :getBanner
end
