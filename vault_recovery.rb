#!/usr/bin/env ruby
# frozen_string_literal: true
require 'bundler'
Bundler.setup

require 'thor'
require 'vault'
require 'json'

# Backport upcoming Object#yield_self
class Object
  def yield_self(*args)
    yield(self, *args)
  end
end
# Our thor CLI interface
class CLI < Thor
  class_option :token, required: true, desc: 'The vault token to use'
  class_option :url, required: true, desc: 'The url to the vault server'

  desc 'backup', 'backup secrets for specific mount path'
  option :path, required: true, desc: 'mount point for secrets'
  $secrets = []
  def backup(secret_mount=options[:path])
    Vault.configure do |config|
      config.address = options[:url]
      config.token = options[:token]
    end
    paths = Vault.logical.list(secret_mount)
    for path in paths
      item_path = secret_mount + path
      if path.end_with?("/")
        backup(item_path)
      else
        print_secret(item_path)
      end
    end
  end

  def print_secret(secret_path)
    content = Vault.logical.read(secret_path)
    secret = content.data
    point, path = secret_path.split("/", 2)
    tempHash = {
      "mount_point" => point,
      "secret_path" => path,
      "secret" => secret
    }
    $secrets<<tempHash
    File.open("backup.json","w") do |f|
      f.write(JSON.pretty_generate($secrets))
    end
  end

  desc 'restore', 'restore secrets from given backup file'
  option :file_path, required: true, desc: 'file path for backup file'

  def restore
    secret_file=options[:file_path]
    Vault.configure do |config|
      config.address = options[:url]
      config.token = options[:token]
    end
    file = File.read("#{secret_file}")
    data = JSON.parse(file)
    data.each do |hash|
      Vault.kv("#{hash['mount_point']}").write("#{hash['secret_path']}",hash['secret'])
    end
  end
end
CLI.start(ARGV)
