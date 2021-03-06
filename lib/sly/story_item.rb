class Sly::StoryItem < Sly::Item
  attr_accessor :who, :what, :why

  def title=(value)
    self.parse_title(value)
  end

  def title
    prefixes = {
      who: "As a",
      what: "I want",
      why: "so that"
    }

    prefixes[:who] += "n" if @who && ["a","e","i","o","h"].include?(@who[0,1])

    prefixes[:who]+" "+@who.to_s+", "+prefixes[:what]+" "+@what.to_s+" "+prefixes[:why]+" "+@why.to_s+"."
  end

  def parse_title(title)
    #default values
    @who = "X"
    @what = "Y"
    @why = "Z"

    regex = /^\s*(?:as an?|aa)\s+(?<who>[^,]+),?\W+(?:i want|iw)\s+(?<what>.+)\W+(?:so that|st)\s+(?<why>.+)/i

    matches = title.match(regex)
    
    if(matches)
      matches.names.each do |name|
        self.send(name.to_s+"=", matches[name])
      end
    end
  end
end