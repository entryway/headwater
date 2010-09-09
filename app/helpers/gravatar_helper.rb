require "digest/md5"

module GravatarHelper
  BASE_URL = "http://www.gravatar.com/avatar/%s"
  
  def gravatar_image_tag_for_email(email_address)
    image_src = gravatar_url_for_email(email_address)
    image_tag(image_src)
  end
  
  def gravatar_url_for_email(email_address)
    hash = Digest::MD5.hexdigest(email_address)
    BASE_URL % hash
  end
end