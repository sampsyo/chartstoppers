module Jekyll
  class PlayerDocument < Document
    def destination(base_directory)
      orig = Jekyll.sanitized_path(base_directory, url)
      File.join(orig, "player.html")
    end
  end

  class PlayerGenerator < Generator
    safe true
    priority :low

    def generate(site)
      col = Collection.new(site, "eps")
      site.collections["ep_players"] = col

      sc = site.config
      pc = site.data["podcast"]
      surl = sc['url']

      site.collections["eps"].docs.each do |ep|
        # Build up some extra metadata for each episode.
        converter = site.getConverterImpl(Jekyll::Converters::Markdown)
        body = converter.convert ep.content
        plainbody = body.gsub /<.*?>/m, ''
        ep.data.merge!({
          "imageurl" => ep.data['image'] ?
                        "#{surl}#{ep.data['image']}" :
                        "#{surl}#{pc['image']}",
          "ogg" => "#{surl}audio/#{ep.data['number']}.ogg",
          "mp3" => "#{surl}audio/#{ep.data['number']}.mp3",
          "synopsis" => "#{sc['name']} ##{ep.data['number']}: " +
                        "“#{ ep.data['title'] }”",
          "summary" => plainbody.split("\n")[0],
        })

        # Optionally generate standalone player documents for Twitter player
        # cards.
        if site.data["podcast"]["player_card"]
          player = PlayerDocument.new(ep.path, { site: site, collection: col })
          player.read
          player.data["layout"] = "player"
          col.docs << player
        end
      end
    end
  end
end
