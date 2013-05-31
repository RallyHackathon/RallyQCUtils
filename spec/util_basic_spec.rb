require 'rspec'
require_relative 'spec_helper'

describe "basic util tests" do

  it 'should read Rally Workspaces and Projects' do
    config = RallyQCUtilsHelper.get_config
    #puts config
    config["RallyConnection"].should_not be_nil

    args = ["create", "test", config]
    util = RallyQCUtils::RallyQCUtil.new(args)
    util.run
  end



end