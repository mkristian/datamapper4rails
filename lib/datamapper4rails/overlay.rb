require 'rails_generator/base'

# this extension allows to reuse generators from other gems by defining
# a search path (list of overlay directories) for template files. these
# overlay directories have preference to the rails template search algorithm.
# the overlay directories can be also given via command line options.

Rails::Generator::NamedBase.class_eval do

  def overlay_array
    a = []
    def a.lookup(clazz)
      @clazz = clazz
    end
    a.lookup(self.class)
    def a.add_generator(generator_name)
      unless frozen?
        path = File.join(@clazz.lookup(generator_name).path, 'templates')
        push(path) unless member? path
      end
    end
    a
  end

  def overlay_dirs
    options[:overlay_dirs] ||= overlay_array
  end

  def add_options!(opt)
    # TODO this seems not to work anymore !!
    super
    opt.on("--overlay-dir DIR",
           "overlay") do |v|
      overlay_dirs << v
    end
  end

  def source_path(relative_source)
    # Check whether we're referring to another generator's file.
    name, path = relative_source.split(':', 2)

    # first check if the template can be found with in any of the overlay directories
    if dirs = options[:overlay_dirs]
      generator_name = self.class.name.underscore.sub(/_generator/, '')
      unless dirs.frozen?
        dirs.insert(0, File.join(self.class.lookup(generator_name).path, 'templates'))
        dirs.freeze
      end
      file = path.nil? ? name : path
      dirs.each do |dir|
        if (f = File.join(dir, file)) and File.exists?(f)
          logger.overlay f if options[:backtrace]
          return f
        end
      end
    end

    # If not, return the full path to our source file.
    if path.nil?
      File.join(source_root, name)

      # Otherwise, ask our referral for the file.
    else
      # FIXME: this is broken, though almost always true.  Others'
      # source_root are not necessarily the templates dir.
      File.join(self.class.lookup(name).path, 'templates', path)
    end
  end
end
