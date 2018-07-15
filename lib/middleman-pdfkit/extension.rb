module Middleman
  module PDFKit
    class Extension < ::Middleman::Extension
      option :filenames, [], 'array of html files without .ext or leave it empty for all html files in build directory'

      # https://github.com/pdfkit/pdfkit/blob/v0.6.2/lib/pdfkit/configuration.rb#L10-L17
      option :disable_smart_shrinking,  false,    'Disable smart shrinking'
      option :quiet,                    true,     'Be quiet'
      option :page_size,                'A4',     'Page size: A4'
      option :margin_top,               '0',      'Margin top: 0'
      option :margin_right,             '0',      'Margin right: 0'
      option :margin_bottom,            '0',      'Margin bottom: 0'
      option :margin_left,              '0',      'Margin left: 0'
      option :encoding,                 'UTF-8',  'Encoding'

      def initialize(klass, options_hash={}, &block)
        super
        setup_filenames
      end

      def after_build(builder)
        # If filename is a classic Array, le's infer the output file name
        if @filenames.is_a?(Array)

          @filenames.each do |file|
            build_pdf_for(file)
          end
        
        # If filename is a Hash, it provides the output file names
        elsif @filenames.is_a?(Hash)

          @filenames.each do |file, output|
            build_pdf_for(file, output)
          end

        end
      end

      private

        def build_pdf_for input, output = nil
          # Build two versions of input files and test them
          file1 = "build/#{input}"
          file2 = "build/#{input}.html"

          # Default output filename if not specified
          outfile ||= "build/#{output}"

          # Test input flies presence
          if File.exist?(file1)
            puts "create", outfile
            generate_pdf(file1, outfile)
          elsif File.exist?(file2)
            puts "create", outfile
            generate_pdf(file2, outfile)
          else
            puts "error", "PDFKit: none of source HTML files [#{file1}, #{file2}] been found", :red
          end
        end

        def setup_filenames
          @filenames = options.filenames.empty? ? all_html_files : options.filenames
        end

        def all_html_files
          # TODO: find a better way?!
          Dir.glob(File.join('build', '**', '*.html')).map do |d|
            File.join(File.dirname(d).sub('build', ''), File.basename(d, '.html'))[1..-1]
          end
        end

        def generate_pdf(html_filename, pdf_filename)
          kit = ::PDFKit.new(File.new(html_filename),
            disable_smart_shrinking:  options.disable_smart_shrinking,
            quiet:                    options.quiet,
            page_size:                options.page_size,
            margin_top:               options.margin_top,
            margin_right:             options.margin_right,
            margin_bottom:            options.margin_bottom,
            margin_left:              options.margin_left,
            encoding:                 options.encoding)
          file = kit.to_file(pdf_filename)
        end

    end
  end
end
