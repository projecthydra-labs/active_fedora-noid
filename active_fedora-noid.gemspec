$:.push File.expand_path('../lib', __FILE__)

require 'active_fedora/noid/version'

Gem::Specification.new do |spec|
  spec.name          = "active_fedora-noid"
  spec.version       = ActiveFedora::Noid::VERSION
  spec.authors       = ["Michael J. Giarlo"]
  spec.email         = ["leftwing@alumni.rutgers.edu"]
  spec.summary       = %q{Noid identifier services for ActiveFedora-based applications}
  spec.description   = %q{Noid identifier services for ActiveFedora-based applications.}
  spec.homepage      = "https://github.com/projecthydra-labs/active_fedora-noid"
  spec.license       = "Apache2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'active-fedora', '>= 9.7', '< 11'
  spec.add_dependency 'noid', '~> 0.7'
  spec.add_dependency 'rails', '~> 4.2.6'

  spec.add_development_dependency 'engine_cart'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'sqlite3'

  spec.post_install_message = <<-END
NOTE: ActiveFedora::Noid 1.0.0 included a change that breaks existing minter
statefiles. Run the `active_fedora:noid:migrate_statefile` rake task to migrate
your statefile. (If you're using a custom statefile, not /tmp/minter-state,, set
an environment variable called AFNOID_STATEFILE with its path.)
END

end
