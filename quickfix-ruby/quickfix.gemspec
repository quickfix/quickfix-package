Gem::Specification.new do |s|
  s.name        = 'quickfix'
  s.version     = '1.14.2'
  s.date        = '2014-09-14'
  s.summary     = "QuickFIX"
  s.description = "FIX (Financial Information eXchange) protocol implementation",
  s.authors     = ["Oren Miller"]
  s.email       = 'oren@quickfixengine.org'
  s.files       = Dir.glob("lib/*.rb") + Dir.glob("ext/quickfix/*.*") + Dir.glob("spec/FIX*.xml") + Dir.glob("test/*") + Dir.glob("Rakefile") 
  s.extensions = %w[ext/quickfix/extconf.rb]
  s.homepage    =
    'http://www.quickfixengine.org'
  s.licenses    = 'Apache Style'
end