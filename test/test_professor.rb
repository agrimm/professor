require 'helper'

class TestProfessor < Test::Unit::TestCase
  include TestProfessorHelper

  def test_vague_semblance_of_roundtripping
    comparison = create_comparison_using_filenames("test/data/basic_profile.txt", "test/data/basic_profile.txt")
    assert_match /String.split/, comparison.output_text, "No vague semblance of round tripping"
  end
end
