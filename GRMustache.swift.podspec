Pod::Spec.new do |s|
	s.name     = 'GRMustache.swift'
	s.version  = '2.0.0'
	s.license  = { :type => 'MIT', :file => 'LICENSE' }
	s.summary  = 'Flexible Mustache templates for Swift.'
	s.homepage = 'https://github.com/groue/GRMustache.swift'
	s.author   = { 'Gwendal Roué' => 'gr@pierlis.com' }
	s.source   = { :git => 'https://github.com/groue/GRMustache.swift.git', :tag => s.version }
	s.source_files = 'Sources/**/*.{h,m,swift}', 'ObjC/**/*.{h,m,swift}'
	s.module_name = 'Mustache'
	s.ios.deployment_target = '8.0'
	s.osx.deployment_target = '10.9'
	s.tvos.deployment_target = '9.0'
	s.requires_arc = true
	s.framework = 'Foundation'
end