module Erector
  module Rails
    class TemplateHandler
      def call(template)
        require_dependency template.identifier
        is_partial = File.basename(template.identifier) =~ /^_/
        <<-SRC
        Erector::Rails.render(#{widget_class_name(template.identifier)}, self, local_assigns, #{!!is_partial})
        SRC
      end

      private
      def widget_class_name(identifier)
        prefix = view_paths.find{ |prefix| identifier.starts_with? prefix }
        raise ArgumentError, "Template is not underneath rails view_paths" if prefix.blank?

        # remove leading slash and trailing .rb
        stripped       = identifier.sub(prefix, "")[1..-4]
        view_path_base = File.basename(prefix)

        "#{view_path_base}/#{stripped}".camelize
      end

      def view_paths
        ::Rails.configuration.action_controller.view_paths
      end
    end
  end
end

ActionView::Template.register_template_handler :rb, Erector::Rails::TemplateHandler.new
