module AWSHelpers

  def upload_to_aws_s3_storage(file, file_name)
    # Upload file to AWS S3: these methods belond to the aws sdk
    object = settings.bucket.object(file_name)
    object.upload_file(file)
    @subtitle_track_url = object.public_url.to_s
  end

end