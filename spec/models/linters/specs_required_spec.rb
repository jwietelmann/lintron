require 'rails_helper'

describe Linters::SpecsRequired do
  let(:pr_missing_rb_spec) do
    PRMissingRBSpec.new
  end

  let(:pr_missing_es_spec) do
    PRMissingESSpec.new
  end

  let(:pr_with_all_specs) do
    PRWithAllSpecs.new
  end

  let(:pr_with_deletion) do
    PRWithDeletion.new
  end

  let(:pr_with_exemption) do
    PRWithExemption.new
  end

  let(:linter) { Linters::SpecsRequired }

  it 'catches missing specs for rb files' do
    violations = linter.run(pr_missing_rb_spec)
    expect(violations.length).to eq 1
    expect(violations.first.message).to include 'post_spec'
  end

  it 'catches missing specs for es6 files' do
    violations = linter.run(pr_missing_es_spec)
    expect(violations.length).to eq 1
    expect(violations.first.message).to include 'post_spec'
  end

  it 'ignores PRs with all the correct specs' do
    violations = linter.run(pr_with_all_specs)
    expect(violations.length).to eq 0
  end

  it 'can handle PRs with deleted files' do
    violations = nil
    expect do
      violations = linter.run(pr_with_deletion)
    end.to_not raise_error
    expect(violations).to be_empty
  end

  it 'ignores exempt directories' do
    violations = linter.run(pr_with_exemption)
    expect(violations.length).to eq 0

    expect(linter.exempt_path?(pr_with_exemption.files.first)).to be true
    expect(linter.requires_spec?(pr_with_exemption.files.first)).to be false
  end

  it 'can get the url where a spec should live' do
    path = 'test.rb'
    body = 'class Test; end'

    file = StubFile.new(
      path: path,
      blob: body,
      patch: Patch.from_file_body(body),
    )

    pr = LocalPrAlike.from_json(
      [
        file.as_json,
      ],
    )

    expect(
      Linters::SpecsRequired.expected_spec_url(pr, file),
    ).to eq 'spec/test_spec.rb'
  end
end
