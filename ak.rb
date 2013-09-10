#! /usr/local/bin/ruby
# AYA 辅助系统

require_relative 'ak/core.rb'

at_exit {
  log "退出"
}

core = AK.new
core.run
