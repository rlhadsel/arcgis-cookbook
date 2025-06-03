#
# Cookbook:: arcgis-repository
# Recipe:: azure_cli
#
# Copyright 2025 Esri
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if node['platform'] == 'windows'
  windows_package 'Install Azure CLI' do
    source node['arcgis']['repository']['azure_cli']['msi_url']
    options '/qn'
    installer_type :msi
    returns [0, 3010, 1638]
    not_if 'az --version'
    action :install
  end

  # Add Azure CLI path to PATH env variable to use in the current Chef run.
  ENV['PATH'] = "#{ENV['PATH']};#{node['arcgis']['repository']['azure_cli']['wbin_dir']}"
else # Install Azure CLI in a virtual python environment
  az = ::File.join(node['arcgis']['repository']['azure_cli']['install_dir'], 'bin', 'az')
  
  # Create a virtual environment 
  package 'python3-venv' do
    only_if { platform_family?('debian') }
  end

  execute "python3 -m venv #{node['arcgis']['repository']['azure_cli']['install_dir']}" do
    guard_interpreter :bash
    not_if "#{az} --version"
  end

  # Update pip
  execute "#{node['arcgis']['repository']['azure_cli']['install_dir']}/bin/python -m pip install --upgrade pip" do
    guard_interpreter :bash
    not_if "#{az} --version"
  end 

  # Install azure-cli in the virtual environment
  execute "#{node['arcgis']['repository']['azure_cli']['install_dir']}/bin/python -m pip install azure-cli" do
    guard_interpreter :bash
    not_if "#{az} --version"
  end
end
