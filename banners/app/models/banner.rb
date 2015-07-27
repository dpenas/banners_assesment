require 'csv'

class Banner < ActiveRecord::Base
    @@banner_id_impressions
    @@click_id
    @@revenue

    def self.getImage(number)
        'image_' + number.to_s + '.png.jpg'
    end

    def self.parseCSV()

        csv_namefiles = ["impressions", "clicks", "conversions"]
        csv_files = Array.new
        impressions = Array.new
        csv_namefiles.each do |file_name|
            directory = "app/assets/csv/" + file_name + "_1.csv"
            csv_files.push(CSV.parse(File.read(directory)))
        end
        return csv_files
    end

    def self.getInformation (array, retrieveColumn1, retrieveColumn2, checkColumn)
        result = Array.new
        array.each do |row|
            if (row.include?(checkColumn))
                array = Array.new
                array.push(row[retrieveColumn1])
                array.push(row[retrieveColumn2])
                result.push(array)
            end
        end
        return result
    end

    def self.obtainRevenue(click_array, conversions)
        revenue = Array.new
        click_array.each do |click|
            conversions.each do |conversion|
                if (conversion[1] == click[0])
                    click_revenue = Array.new
                    click_revenue.push(click[0])
                    click_revenue.push(conversion[2])
                    revenue.push(click_revenue)
                end
            end
        end
        @@revenue = revenue
    end

    def self.obtainBannersFromRevenue(limit)
        final_banners_id = Array.new
        (@@revenue.sort_by{|e| e[1]}).last(limit).each do |row_revenue|
            @@click_id.each do |row_clicks|
                if (row_revenue[0] == row_clicks[0])
                    final_banners_id.push(row_clicks[1])
                end
            end
        end
        return final_banners_id.reverse
    end

    def self.getAllBanners(impressions_file)
        banners_id = Array.new
        impressions_file.each do |row|
            banners_id.push(row[0])
        end
        # Removed first element (column name)
        banners_id.shift
        return banners_id
    end

    def self.obtainBannersFromClicks(banners, limit, impressions_file)
        counts = Hash.new 0
        banners_count = banners.count
        @@click_id.each do |row|
            counts[row[1]] += 1
        end
        counts.sort_by{|banner_id, click_count| -click_count}.each do |row|
            unless (banners.include? row[0])
                banners.push(row[0])
            end
            if (banners.count == limit)
                return banners
            end
        end
        if (banners.count < limit)
            all_banners = getAllBanners(impressions_file)
            while (banners.count < limit) do
                rand_number = rand(all_banners.count)
                unless (banners.include? all_banners[rand_number])
                    banners.push(all_banners[rand_number])
                end
            end
        end
        return banners
    end

    def self.obtainBannersBasedOnRevenueAndClicks(impressions_file)
        final_banners_id = Array.new
        max_number_banners = 5
        banners = obtainBannersFromRevenue(@@revenue.count)
        return obtainBannersFromClicks(banners, max_number_banners, impressions_file)

    end

    def self.selectRightBanners(impressions_file)
        if @@revenue.count > 10
            return obtainBannersFromRevenue(10)
        elsif @@revenue.count > 5
            return obtainBannersFromRevenue(5)
        else @@revenue.count
            return obtainBannersBasedOnRevenueAndClicks(impressions_file)
        end
    end

    def self.getBannerSessions(banners, session)
        if (session[:banners_showed] == nil)
            session[:banners_showed] = Array.new
        end
        eligible_banners = banners - session[:banners_showed]
        if (eligible_banners.count > 0)
            random_number = rand(eligible_banners.count)
            banner = eligible_banners[random_number]
        else
            random_number = rand(banners[banners.count])
            banner = banners[random_number]
        end
        session[:banners_showed] = session[:banners_showed].push(banner)
        return banner
    end

    def self.execute(params, session)
        csv_files = parseCSV()
        # Getting banner_id from impressions file
        @@banner_id_impressions = getInformation(csv_files[0], 0, 1, params['id'])
        # Getting click_id from clicks file
        @@click_id = getInformation(csv_files[1], 0, 1, params['id'])
        # Getting revenue from conversions file
        obtainRevenue(@@click_id, csv_files[2])
        banner = getBannerSessions(selectRightBanners(csv_files[0]), session)
        return getImage(banner)

    end
end
