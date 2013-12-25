require "uri"
require "digest"
require "fileutils"
load File.expand_path "../extract_page.rb", __FILE__

class FetchPage
  @queue = :cnet
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
