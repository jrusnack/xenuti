# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'
require 'xenuti/scanners/static_analyzer_shared'
require 'helpers/alpha_helper'

describe Xenuti::Brakeman do
  let(:config) { Xenuti::Config.from_yaml(File.new(CONFIG_FILEPATH).read) }
  let(:alpha_config) { Xenuti::Config.from_yaml(File.new(ALPHA_CONFIG).read) }
  let(:brakeman) { Xenuti::Brakeman.new(config) }
  let(:alpha_brakeman) { Xenuti::Brakeman.new(alpha_config) }
  let(:brakeman_output) { File.new(BRAKEMAN_OUTPUT).read }

  it_behaves_like 'static_analyzer', Xenuti::Brakeman

  describe '#initialize' do
    it 'should load config file' do
      expect(brakeman.config.brakeman.enabled).to be_true
    end
  end

  describe '#name' do
    it 'should be brakeman' do
      expect(brakeman.name).to be_eql('brakeman')
    end
  end

  describe '#version' do
    it 'should return string with Brakeman version' do
      expect(brakeman.version).to match(/\A\d\.\d\.\d\Z/)
    end
  end

  describe '#run_scan' do
    it 'throws exception when called disabled' do
      config.brakeman.enabled = false
      expect { brakeman.run_scan }.to raise_error(RuntimeError)
    end

    it 'runs scan and captures Brakeman output' do
      # Small hack - I don`t want to clone the repo to get source, so just
      # hardcode it like this
      alpha_config.general.source = alpha_config.general.repo

      # By default alpha_config has all scanners disabled.
      alpha_config.brakeman.enabled = true

      expect(alpha_brakeman.instance_variable_get('@results')).to be_nil
      alpha_brakeman.run_scan
      expect(alpha_brakeman.instance_variable_get('@results')).to be_a(String)
    end
  end

  describe '#parse_results' do
    it 'should parse brakeman output into Xenuti::Report correctly' do
      report = brakeman.parse_results(brakeman_output)
      expect(report).to be_a(Xenuti::Report)
      expect(report.warnings[1]['warning_code']).to be_eql(73)
    end
  end
end
