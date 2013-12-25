require "uri"
require "digest"
require "fileutils"
require "open-uri"
require "resque"
load File.expand_path "../extract_page.rb", __FILE__

class FetchPage
  @queue = :cnet_fetch
  def self.perform(url)
    url_hash = Digest::SHA256.hexdigest url.to_s

    dir = File.expand_path "../../tmp/pages", __FILE__
    FileUtils.mkdir_p dir
    path = File.join dir, "#{url_hash}.html"

    data = open(url).read
    open(path, "w") do |f|
      f.write(data)
      Resque.enqueue ExtractPage, url
    end
  end
end
