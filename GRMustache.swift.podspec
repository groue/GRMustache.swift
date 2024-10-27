Pod::Spec.new do |s|
	s.name     = 'GRMustache.swift'
	s.version  = '5.0.1'
	s.license  = { :type => 'MIT', :file => 'LICENSE' }
	s.summary  = 'Flexible Mustache templates for Swift.'
	s.homepage = 'https://github.com/groue/GRMustache.swift'
	s.author   = { 'Gwendal Roué' => 'gr@pierlis.com' }
	s.source   = { :git => 'https://github.com/groue/GRMustache.swift.git', :tag => s.version }
	s.source_files = 'Sources/**/*.{h,m,swift}', 'ObjC/**/*.{h,m,swift}'
	s.module_name = 'Mustache'
	s.swift_version = '5.9'
	s.ios.deployment_target = '11.0'
	s.osx.deployment_target = '10.11'
	s.tvos.deployment_target = '9.0'
	s.requires_arc = true
	s.framework = 'Foundation'
end
