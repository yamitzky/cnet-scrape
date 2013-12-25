require "digest"
require "nokogiri"
require "sqlite3"

class ExtractPage
  @queue = :cnet
  def self.perform(url)
    url_hash = Digest::SHA256.hexdigest url.to_s

    path = File.expand_path "../../tmp/pages/#{url_hash}.html", __FILE__
    doc = Nokogiri::HTML open(path)
    paragraphs = doc.css("article#contentBody .postBody p")
    if paragraphs.empty?
      return
    end

    body = paragraphs.map{|el| el.text.strip}.join("\n")
    time = DateTime.parse(doc.css("time.datestamp").text)
    tags = doc.css("div[section=tags] dd a").map{|el| el.text.strip}

    db_path = File.expand_path "../../tmp/cnet.db", __FILE__
    db = SQLite3::Database.new db_path
    db.execute(
      "UPDATE pages SET published_at = ?, body = ? WHERE url = ?",
      time.strftime("%Y-%m-%d %T"), body, url
    )
    tags.each do |tag|
      db.execute(
        "INSERT OR IGNORE INTO page_tags VALUES(?, ?)",
        url, tag
      )
    end
  end
end
