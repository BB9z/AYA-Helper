#! /usr/bin/env ruby
# AYA 辅助系统

require_relative 'ak/core.rb'

at_exit {
  puts caller
  log "退出"
}

core = AK.new
core.run
