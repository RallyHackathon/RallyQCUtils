require 'rspec'
require "spec_helper"

describe 'QC Connection tests' do

  it 'should read a list of qc domains' do
    config = RallyQCUtilsHelper.get_config
    qc_config = {
        :url            => config["QCConnection"]["Url"],
        :qc_user        => config["QCConnection"]["User"],
        :qc_password    => config["QCConnection"]["Password"],
        :artifact_type  => config["QCConnection"]["ArtifactType"]
    }
    qc = RallyQCUtils::QCConnection.new(qc_config)
    qc_data = qc.gather_qc_info
    puts qc_data
    qc_data.length.should > 0
  end

end