require 'helper'

class TestProfessor < Test::Unit::TestCase
  include TestProfessorHelper

  def test_vague_semblance_of_roundtripping
    comparison = create_comparison_using_filenames("test/data/basic_profile.txt", "test/data/basic_profile.txt")
    assert_match /String.split/, comparison.output_text, "No vague semblance of round tripping"
  end

  def test_report_statistics_from_old_and_new
    comparison = create_comparison_using_filenames("test/data/basic_profile.txt", "test/data/modified_basic_profile.txt")
    method_comparison_report_line = get_report_line(comparison, "Kernel#gem_original_require")
    old_self_percent_regexp = /75.87/
    new_self_percent_regexp = /74.87/
    assert_match old_self_percent_regexp, method_comparison_report_line, "Doesn't include old self percent"
    assert_match new_self_percent_regexp, method_comparison_report_line, "Doesn't include new self percent"
  end

  def test_report_statistics_delta
    comparison = create_comparison_using_filenames("test/data/basic_profile.txt", "test/data/modified_basic_profile.txt")
    method_comparison_report_line = get_report_line(comparison, "Kernel#gem_original_require")
    delta_self_percent_regexp = /-1.0/
    assert_match delta_self_percent_regexp, method_comparison_report_line, "Doesn't include change in self percent percent"
  end
end
