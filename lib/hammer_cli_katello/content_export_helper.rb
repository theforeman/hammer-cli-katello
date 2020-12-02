module HammerCLIKatello
  module ContentExportHelper
    include ApipieHelper
    def execute
      response = super
      if option_async? || response != HammerCLI::EX_OK
        response
      else
        export_history = fetch_export_history(@task)
        if export_history
          generate_metadata_json(export_history)
          HammerCLI::EX_OK
        else
          output.print_error _("Could not fetch the export history")
          HammerCLI::EX_CANTCREAT
        end
      end
    end

    def task_progress(task_or_id)
      super
      @task = reload_task(task_or_id)
    end

    def reload_task(task)
      task_id = if task.is_a? Hash
                  task['id']
                else
                  task
                end
      show(:foreman_tasks, id: task_id)
    end

    def fetch_export_history(task)
      export_history_id = task["output"]["export_history_id"]
      index(:content_exports, :id => export_history_id).first if export_history_id
    end

    def generate_metadata_json(export_history)
      metadata_json = export_history["metadata"].to_json
      begin
        metadata_path = "#{export_history['path']}/metadata.json"
        File.write(metadata_path, metadata_json)
        output.print_message _("Generated #{metadata_path}")
      rescue SystemCallError
        filename = "metadata-#{export_history['id']}.json"
        File.write(filename, metadata_json)
        output.print_message _("Unable to access/write to '#{export_history['path']}'. "\
                               "Generated '#{Dir.pwd}/#{filename}' instead. "\
                               "You would need this file for importing.")
      end
    end

    def self.included(base)
      if base.command_name.first.to_sym == :version
        setup_version(base)
      elsif base.command_name.first.to_sym == :library
        setup_library(base)
      end
    end

    def self.setup_library(base)
      base.action(:library)
      base.success_message _("Library environment is being exported in task %{id}.")
      base.failure_message _("Could not export the library")
      base.build_options do |o|
        o.expand(:all).including(:organizations)
      end
    end

    def self.setup_version(base)
      base.action(:version)
      base.build_options do |o|
        o.expand(:all).including(:content_views, :organizations)
      end

      base.option "--version", "VERSION", _("Filter versions by version number."),
                 :attribute_name => :option_version,
                 :required => false

      base.success_message _("Content view version is being exported in task %{id}.")
      base.failure_message _("Could not export the content view version")

      base.class_eval do
        def request_params
          super.tap do |opts|
            opts["id"] = resolver.content_view_version_id(options)
          end
        end
      end
    end
  end
end