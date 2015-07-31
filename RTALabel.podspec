
Pod::Spec.new do |s|
  s.name         = "RTALabel"
  s.version      = "0.0.1"
  s.summary      = "Rich text parser for UILabel"

  s.description  = <<-DESC
                   a rich text parser for UILabel to use html-like markups
                   DESC

  s.homepage     = "https://github.com/shiyj/RTALabel"

  s.source       = {:git => "https://github.com/shiyj/RTALabel.git", :branch => 'master'}

  s.license      = { :type => 'MIT', :text => <<-LICENSE
                      CopyLeft 2015
                    LICENSE
                    }
  s.author             = { "shiyj" => "shiyj.cn@gmail.com" }

  s.platform     = :ios, "7.0"

  s.source_files = 'Lib/*.{h,m,mm}'
end