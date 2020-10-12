require File.join(File.dirname(__FILE__), '../../test_helper')
require 'hammer_cli_katello/content_view_version'

describe 'content-view version export-histories' do
  let(:empty_response) do
    {
      "total" => 0,
      "subtotal" => 0,
      "page" => "1",
      "per_page" => "1000",
      "error" => nil,
      "search" => nil,
      "sort" => {
        "by" => nil,
        "order" => nil
      },
      "results" => []
    }
  end

  it 'allows minimal options' do
    ex = api_expects(:content_view_versions, :export_histories)

    ex.returns(empty_response)
    # rubocop:disable LineLength
    expected_result = success_result('---|--------------------|------|----------------------|-------------------------|------------|-----------
ID | DESTINATION SERVER | PATH | CONTENT VIEW VERSION | CONTENT VIEW VERSION ID | CREATED AT | UPDATED AT
---|--------------------|------|----------------------|-------------------------|------------|-----------
')
    # rubocop:enable LineLength
    result = run_cmd(%w(content-view version export-histories))
    assert_cmd(expected_result, result)
  end
end
