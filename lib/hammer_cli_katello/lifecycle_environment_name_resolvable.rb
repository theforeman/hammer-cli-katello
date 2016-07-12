module HammerCLIKatello
  module LifecycleEnvironmentNameResolvable
    def all_options
      @all_options ||= super.clone

      @all_options['option_lifecycle_environment_organization_id'] ||= (
        @all_options['option_organization_id'] ||= resolver.organization_id(
          resolver.scoped_options('organization', @all_options)
        )
      ) if @all_options['option_organization_name']

      @all_options['option_organization_ids'] ||= resolver.organization_ids(
        resolver.scoped_options('organization', @all_options)
      ) if @all_options['option_organization_names']

      if @all_options['option_lifecycle_environment_name']
        @all_options['option_lifecycle_environment_id'] ||= resolver.lifecycle_environment_id(
          resolver.scoped_options('lifecycle_environment', @all_options).merge(search_query)
        )
      end
      @all_options
    end

    def search_query
      search = ''

      if @all_options['option_organization_ids']
        search += "organization_id=#{@all_options['option_organization_ids']
          .join(' or organization_id=')}"
      end

      { 'option_search' => search }
    end
  end
end
