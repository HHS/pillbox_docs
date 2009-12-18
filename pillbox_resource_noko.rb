require 'nokogiri'
require 'open-uri'
class PillboxResourceNoko
  attr_accessor :attrs
  def PillboxResourceNoko::find_first_with_img_by_ingredient(ingredient)
    prs = PillboxResourceNoko.find_all_by_ingredient(ingredient)
    pill = nil
    prs.each do |pr|
      pill = pr if pr.has_image?
    end
    pill
  end
  def PillboxResourceNoko::find_all_by_ingredient(ingredient)
    doc = Nokogiri::XML(open("http://pillbox.nlm.nih.gov/PHP/pillboxAPIService.php?key=12345&ingredient=#{ingredient}"))
    prs = []
    doc.xpath('//Pills/pill').each do |pill|
      pr = PillboxResourceNoko.new
      pr.attrs = {}
      pill.children.each do |child|
        next if child.nil? or child.name == "text"
        pr.attrs[child.name] = child.inner_html
      end
      prs << pr
    end
    prs
  end

  def shape; attrs['SPLSHAPE'] end
  def color; attrs['SPLCOLOR'] end

  def description; attrs['RXSTRING'] end
  def product_code; attrs['PRODUCT_CODE'] end
  def has_image?; attrs['HAS_IMAGE'] == '1' end
  def ingredients; attrs['INGREDIENTS'].split(";") end
  def size; attrs['SPLSIZE'].to_i end
  def image_id; attrs['image_id'] end
  def image_url; image_id ? "http://pillbox.nlm.nih.gov/assets/super_small/#{image_id}ss.png" : nil end
  #def image_url; image_id ? "http://pillbox.nlm.nih.gov/assets/small/#{image_id}sm.jpg" : nil end
  def imprint; attrs['splimprint'] end
end
