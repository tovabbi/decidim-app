# frozen_string_literal: true

# Copies every translation edited in core-hu.yml (a local copy of Decidim's
# decidim-core hu.yml) into config/locales/hu_overrides.yml.
#
# A text changed back to the original is removed from the overrides again.
# Overrides of keys that are not in decidim-core are left untouched.
#
#   ruby --disable-gems script/sync_hu_overrides.rb          # sync once
#   ruby --disable-gems script/sync_hu_overrides.rb --watch  # sync on every save
require "yaml"

ROOT = File.expand_path("..", __dir__)
EDITED = File.join(ROOT, "core-hu.yml")
ORIGINAL = File.join(__dir__, "hu_overrides", "decidim-core-hu.original.yml")
OVERRIDES = File.join(ROOT, "config", "locales", "hu_overrides.yml")

def load_yaml(path)
  YAML.load_file(path, aliases: true) || {}
end

def flatten(hash, prefix = [], out = {})
  hash.each do |key, value|
    path = prefix + [key]
    value.is_a?(Hash) ? flatten(value, path, out) : out[path] = value
  end
  out
end

def set_path(hash, path, value)
  *parents, leaf = path
  node = parents.reduce(hash) { |current, key| current[key] = current[key].is_a?(Hash) ? current[key] : {} }
  node[leaf] = value
end

def delete_path(hash, path)
  key, *rest = path
  return hash.delete(key) if rest.empty?
  return unless hash[key].is_a?(Hash)

  removed = delete_path(hash[key], rest)
  hash.delete(key) if hash[key].empty?
  removed
end

def sync
  original = flatten(load_yaml(ORIGINAL))
  edited = flatten(load_yaml(EDITED))
  overrides = File.exist?(OVERRIDES) ? load_yaml(OVERRIDES) : {}
  current = flatten(overrides)
  log = []

  original.each do |path, original_value|
    key = path.join(".")
    unless edited.key?(path)
      log << "! missing in core-hu.yml (ignored): #{key}"
      next
    end

    value = edited[path]
    if value != original_value
      next if current[path] == value

      set_path(overrides, path, value)
      log << "~ #{key}: #{value.inspect}"
    elsif current.key?(path)
      delete_path(overrides, path)
      log << "- #{key} (back to original)"
    end
  end

  (edited.keys - original.keys).each { |path| log << "! not a Decidim key (ignored): #{path.join(".")}" }

  if log.any? { |line| line.start_with?("~", "-") }
    File.write(OVERRIDES, YAML.dump(overrides, line_width: -1).delete_prefix("---\n"))
    log << "hu_overrides.yml updated"
  else
    log << "hu_overrides.yml already up to date"
  end
  puts "[#{Time.now.strftime("%H:%M:%S")}]", log
rescue Psych::SyntaxError => e
  puts "[#{Time.now.strftime("%H:%M:%S")}] core-hu.yml is not valid YAML, nothing changed:", e.message
end

if ARGV.include?("--watch")
  puts "Watching core-hu.yml (Ctrl+C to stop)"
  last_mtime = nil
  loop do
    mtime = File.exist?(EDITED) && File.mtime(EDITED)
    if mtime && mtime != last_mtime
      last_mtime = mtime
      sync
    end
    sleep 1
  end
else
  sync
end
