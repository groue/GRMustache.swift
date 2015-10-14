Pod::Spec.new do |s|
	s.name     = 'GRMustache.swift'
	s.version  = '0.11.0'
	s.license  = { :type => 'MIT', :file => 'LICENSE' }
	s.summary  = 'Flexible Mustache templates for Swift.'
	s.homepage = 'https://github.com/groue/GRMustache.swift'
	s.author   = { 'Gwendal Roué' => 'gr@pierlis.com' }
	s.source   = { :git => 'https://github.com/groue/GRMustache.swift.git', :tag => "v#{s.version}" }
	s.source_files = 'Mustache/**/*.{h,m,swift}'
	s.module_name = 'Mustache'
	s.ios.deployment_target = '8.0'
	s.osx.deployment_target = '10.9'
	s.requires_arc = true
	s.framework = 'Foundation'
end