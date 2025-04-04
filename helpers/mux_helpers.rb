require 'mux_ruby'

module MuxHelpers

  def debugger_logger
    print Time.now, ': '
    puts "These are the current assets in the Mux:"
    p assets
    puts "These are the current number of assets:"
    p assets.count
  end

  def special_endpoint
    mux_uploader_api = MuxRuby::DirectUploadsApi.new
    create_asset_request = MuxRuby::CreateAssetRequest.new
    create_asset_request.playback_policy = [MuxRuby::PlaybackPolicy::PUBLIC]
    create_asset_request.encoding_tier = "baseline"

    create_upload_request = MuxRuby::CreateUploadRequest.new
    create_upload_request.new_asset_settings = create_asset_request
    create_upload_request.timeout = 3600
    create_upload_request.cors_origin = 'http://localhost:9292/admin'

    uploaded_video = mux_uploader_api.create_direct_upload(create_upload_request)
    uploaded_asset_id = uploaded_video.data.id
    puts "This is the upload_id: #{uploaded_asset_id}"
    playback_id_for_latest_asset
    uploaded_video.data.url
  end

  def playback_id_for_latest_asset
    assets_api = MuxRuby::AssetsApi.new
    assets = assets_api.list_assets
    if assets && assets.data && !assets.data.empty?
      p 'The last data from assets is:'
      p assets.data.first
      p 'The playback_id for the last asset is:'
      p assets.data.first.playback_ids.first.id
    else
      "Nothing here yet"
    end
  end

  def asset_id_for_latest_asset
    assets_api = MuxRuby::AssetsApi.new
    assets = assets_api.list_assets
    if assets && assets.data && !assets.data.empty?
      # assets = assets_api.list_assets
      assets.data.first.id
    else
      p "There are no assets currently in the Mux storage..."
    end
    # assets.data.first.id
  end

  def duration_for_last_asset_uploaded
    assets_api = MuxRuby::AssetsApi.new
    assets = assets_api.list_assets
    if assets && assets.data && !assets.data.empty?
      assets.data.first.duration
    else
      p "There are no assets currently in the Mux storage..."
    end
  end

  def subtitle_track_info_for_last_upload
    assets_api = MuxRuby::AssetsApi.new
    assets = assets_api.list_assets
    if assets && assets.data && !assets.data.empty?
        @subtitle_language_codes = []
        @subtitle_names = []

      tracks = assets.data.first.tracks

      tracks.each do |track|

        if track.type == "text"
          @subtitle_language_codes.append(track.language_code)
          @subtitle_names.append(track.name)
        end
      end
        @subtitle_language_codes = @subtitle_language_codes.join(", ")
        @subtitle_names = @subtitle_names.join(", ")
    else
      p "There are no assets currently in the Mux storage..."
    end
  end

  def update_subtitle_track_info_for(asset_id)
    database_asset = Asset.find_by(asset_id: asset_id)
    # puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+UPDATESUBSSS"
    assets_api = MuxRuby::AssetsApi.new
    # p assets_api.get_asset(asset_id)
    # p asset
    mux_asset = assets_api.get_asset(asset_id).data
    tracks = mux_asset.tracks
    # puts "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+UPDATESUBSSS"
    @subtitle_language_codes = []
    @subtitle_names = []
    tracks.each do |track|
      if track.type == "text"
        @subtitle_language_codes.append(track.language_code)
        @subtitle_names.append(track.name)
      end
    end
    subtitle_language_codes = @subtitle_language_codes.join(", ")
    subtitle_names = @subtitle_names.join(", ")

    database_asset.update(
      subtitle_language_codes: subtitle_language_codes,
      subtitle_names: subtitle_names
    )
  end


  def create_track_request_for_subtitle(subtitle_track_url, language_code, subtitle_name)
    MuxRuby::CreateTrackRequest.new(
      url: subtitle_track_url,
      type: 'text',
      text_type: 'subtitles',
      language_code: language_code,
      name: subtitle_name,
      closed_captions: false
    )
  end

end

