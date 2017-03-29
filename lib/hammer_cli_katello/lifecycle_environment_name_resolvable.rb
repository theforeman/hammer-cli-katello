module HammerCLIKatello
  module LifecycleEnvironmentNameResolvable
    def lifecycle_environment_resolve_options(options)
      {
        HammerCLI.option_accessor_name("name") => options['option_environment_name'],
        HammerCLI.option_accessor_name("id") => options['option_environment_id'],
        HammerCLI.option_accessor_name("organization_id") => options["option_organization_id"],
        HammerCLI.option_accessor_name("organization_name") => options["option_organization_name"]
      }
    end

    def all_options
      if super['option_environment_name'] && super['option_environment_id'].nil?
        super['option_environment_id'] = resolver.lifecycle_environment_id(
          lifecycle_environment_resolve_options(super))
      end
      super
    end
  end
end
