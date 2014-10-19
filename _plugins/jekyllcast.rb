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

      if site.data["podcast"]["player_card"]
        site.collections["eps"].docs.each do |ep|
          player = PlayerDocument.new(ep.path, { site: site, collection: col })
          player.read
          player.data["layout"] = "player"
          col.docs << player
        end
      end
    end
  end
end
