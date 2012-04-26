group 'js' do
  guard 'jasmine' do
    watch(%r{app/assets/javascripts/(.+)\.js\.coffee$})   { "spec/javascripts" }
    watch(%r{spec/javascripts/.*$})                       { "spec/javascripts" }
  end
end
