# PirateHub

This is the _beta_ version

# To run

Currently, `.env` file is ignored from version control.
In order for it to run, write your own `.env` with necessary credentials.

```
touch .env
```

inside the `.env`:

```
MUX_TOKEN_ID=[your mux ID token]
MUX_TOKEN_SECRET=[your mux token secret key]
```

:NOTE: perhaps these keys should be put inside of the GitHub env variables.

_To run the app:_

.Install dependencies:
```
bundle install
```

.Run the app:
```
rackup
```

# Plan

_To be inserted, currently in Obisidian_

# Notes
_To be inserted, currently in Obisidian_


.Notes on attaching metadata to an asset
```ruby
  def special_endpoint
        # API Client Initialization #
        assets_api = MuxRuby::AssetsApi.new
        playback_ids_api = MuxRuby::PlaybackIDApi.new
        uploads_api = MuxRuby::DirectUploadsApi.new
        # ========== create-direct-upload ==========
        create_asset_request = MuxRuby::CreateAssetRequest.new
        create_asset_request.playback_policy = [MuxRuby::PlaybackPolicy::PUBLIC]
  
        create_upload_request = MuxRuby::CreateUploadRequest.new

        # TRY AND PUT THE FORM SOMEWHERE IN HERE FOR PASSING IN TITLE, DESCRIPTION, and TAG....
        # def add_metadata(playbackID, ASSETID, title, description, tags)
        # put title in data base
        # put ASSETID in db
        # put playbackID in db
        # put description in db
        # end

        # If you cant do it this way, then you can first upload the file
        #and then submit the details after by taking the last entry, and updating the last entry

        # So it would upload, the bar would load and fill as it does,
        # and then the user would need to upload the details and metadata after
        # and click "submit"
  
        create_upload_request.new_asset_settings = create_asset_request
        create_upload_request.timeout = 3600
        create_upload_request.cors_origin = "http://localhost:9292/admin"
  
        upload = uploads_api.create_direct_upload(create_upload_request)
  
        endpoint= upload.data.url
        endpoint
  end

# TODO:extract the playback ID and allow input for title,
# description, tags/genre to be inserted and updated,
# for the admin to change.

```

# Resources

_To be inserted, currently in Obisidian_

- Mux upload a video:

https://docs.mux.com/guides/mux-uploader#upload-a-video

- Mux for creating a new direct upload URL:
https://docs.mux.com/api-reference#video/operation/create-direct-upload

- Mux slot reference:
https://docs.mux.com/guides/mux-uploader#slots-reference


- mux-ruby-sdk on github:
https://github.com/muxinc/mux-ruby?tab=readme-ov-file


- Consulted for uploading a file:
https://azemoh.com/2016/05/17/sinatra-managing-file-uploads/
