# encoding: utf-8

module Boilerplate

module ViewHelper
  def page
    settings.page
  end

  def fab
    page[:fab]
  end

  def notification
    page[:notification]
  end

  def view(path, options = {})
    # @page && @page[:layout] && options.update(layout: @page[:layout].to_sym)
    options[:layout] && (options[:layout] = options[:layout].to_sym)
    erb(path.to_sym, options)
  end

  def partial(path, options = {})
    options.merge! layout: false
    pathname = partial_pathname(path)
    if collection = options.delete(:collection) then
      collection.inject([]) do |buffer, member|
        buffer << erb(pathname, options.merge(locals: { pathname.to_sym => member }))
      end.join("\n")
    else
      erb(pathname.to_sym, options)
    end
  end

  def remove_html_tags(text)
    text.gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, '')
  end

  def letters
    Hash[('A'..'Z').to_a.map{|i| [i, []]}]
  end

  def sanitize_letter(letter)
    case letter
    when /ÁÀÄÂÃ/  then 'A'
    when /áàäôã/  then 'a'
    when /ÉÈËÊ/   then 'E'
    when /éèëê/   then 'e'
    when /ÍÌÏÎ/   then 'I'
    when /íìïî/   then 'i'
    when /ÓÒÖÔÕ/  then 'O'
    when /óòöôõ/  then 'o'
    when /ÚÙÜÛŨ/  then 'U'
    when /úùüûũ/  then 'u'
    else letter
    end
  end

  private

  def partial_pathname(path)
    dirname, basename = File.dirname(path.to_s), File.basename(path.to_s) 
    basename.insert 0, "_"
    File.join(dirname == "." ? [basename] : [dirname, basename]).to_sym
  end
end

end # Boilerplate
