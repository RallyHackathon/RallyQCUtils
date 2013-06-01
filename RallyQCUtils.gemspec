# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'RallyQCUtils/version'

Gem::Specification.new do |spec|
  spec.name          = "RallyQCUtils"
  spec.version       = RallyQCUtils::VERSION
  spec.authors       = ["Dave Smith"]
  spec.email         = ["dsmith@rallydev.com"]
  spec.description   = %q{RallyQCUtils is a utility meant to help you setup the RallyQC Connector when you have many QC Domains and Projects
              It can create a template spreadsheet for you to generate configuration files from.
              The generated spreadsheet will contain 3 tabs:

              1.  A Rally Tab with a list of Rally Workspaces, Workspace IDs, Projects, and Project IDs.
              2.  A QC Tab with a list of QC Domains and their corresponding Projects
              3.  A Data tab where you can paste in your QC Domain Project List and map the corresponding Rally Workspace / Project
                  Columns further to the right can map the Rally Field to the intended QC Field listed in the header.

              The generate command will read the template spreadsheet and create configuration files in a specified location.
              The generated configs will be named QCDomain_QCProject_Type.xml.  Ex.  DEFAULT_Project1_REQ.xml}
  spec.summary       = %q{A utility to help you setup the RallyQC Connector}
  spec.homepage      = "https://github.com/RallyHackathon/RallyQCUtils"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rally_api", "~> 0.9"
  spec.add_dependency "nori"
  spec.add_dependency "nokogiri"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
