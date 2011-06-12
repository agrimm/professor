class Professor

  def self.create_comparison(old_rdoc_filename, new_rdoc_filename)
    raise "Missing files" unless [old_rdoc_filename, new_rdoc_filename].all?{|filename| filename and File.exist?(filename)}
    Comparison.new_using_filenames(old_rdoc_filename, new_rdoc_filename)
  end

  class RDoc
    class Report
      attr_reader :method_reports
      def self.new_using_filename(rdoc_filename)
        # FIXME determining the lines is hacky
        method_reports = File.readlines(rdoc_filename)[4..-3].map do |line|
          method_report = MethodReport.new_using_line(line)
        end
        report = new(method_reports)
        report
      end

      def initialize(method_reports)
        @method_reports = method_reports
      end
    end

    class MethodReport
      attr_reader :self_percent, :total_percent, :self_absolute, :wait_absolute, :child_absolute, :calls, :name

      def self.new_using_line(line)
        # FIXME splitting up the line is slightly hacky
        cells = line.strip.split(/  +/).map(&:strip)
        self_percent, total_percent, self_absolute, wait_absolute, child_absolute = cells[0..5].map{|cell| Float(cell)}
        calls = Integer(cells[5])
        name = cells[6]
        method_report = new(self_percent, total_percent, self_absolute, wait_absolute, child_absolute, calls, name)
        method_report
      end

      def initialize(self_percent, total_percent, self_absolute, wait_absolute, child_absolute, calls, name)
        @self_percent, @total_percent, @self_absolute, @wait_absolute, @child_absolute, @calls, @name = self_percent, total_percent, self_absolute, wait_absolute, child_absolute, calls, name
      end

      def statistics_portion
        [@self_percent, @total_percent, @self_absolute, @wait_absolute, @child_absolute, @calls].join("\t")
      end
    end
  end

  class Comparison
    attr_reader :method_comparisons

    def self.new_using_filenames(old_rdoc_filename, new_rdoc_filename)
      old_rdoc_report, new_rdoc_report = [old_rdoc_filename, new_rdoc_filename].map{|filename| RDoc::Report.new_using_filename(filename)}
      new(old_rdoc_report, new_rdoc_report)
    end

    def initialize(old_rdoc_report, new_rdoc_report)
      @method_comparisons = determine_method_comparisons(old_rdoc_report.method_reports, new_rdoc_report.method_reports)
    end

    def determine_method_comparisons(old_rdoc_method_reports, new_rdoc_method_reports)
      # FIXME assumption of a one to one mapping of methods
      old_rdoc_method_reports.zip(new_rdoc_method_reports).map do |old_rdoc_method_report, new_rdoc_method_report|
        method_comparison = MethodComparison.new(old_rdoc_method_report, new_rdoc_method_report)
      end
    end

    def output_comparison(output_filename)
      File.open(output_filename, "w") {|f| f.print(output_text)}
    end

    def output_text
      first_heading_line = ["Old", "New", "Difference"].join("\t" * 6)
      second_heading_line = ("%self     total     self     wait    child    calls".split(/ +/).*(3)+["name"]).join("\t")
      body_lines = method_comparisons.map(&:output_line)
      ([first_heading_line, second_heading_line] + body_lines).join("\n")
    end
  end

  class MethodComparison
    def initialize(old_rdoc_method_report, new_rdoc_method_report)
      @old_rdoc_method_report = old_rdoc_method_report
      @new_rdoc_method_report = new_rdoc_method_report
    end

    def method_name
      @new_rdoc_method_report.name
    end

    def statistics_delta_portion
      statistic_deltas = [:self_percent, :total_percent, :self_absolute, :wait_absolute, :child_absolute, :calls].map do |statistic_name|
        @new_rdoc_method_report.send(statistic_name) - @old_rdoc_method_report.send(statistic_name)
      end
      statistic_deltas.map{|f| sprintf("%.2f", f)}.join("\t")
    end

    def output_line
      # FIXME add more information
      report_statistics_string = [@old_rdoc_method_report, @new_rdoc_method_report].map(&:statistics_portion).join("\t")
      [report_statistics_string, statistics_delta_portion, method_name].join("\t")
    end
  end
end
