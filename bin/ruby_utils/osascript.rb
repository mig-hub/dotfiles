def osascript script
  Kernel.system 'osascript', *script.split(/\n/).map { |line| [ '-e', line ] }.flatten
end

# Usage:
#
# osascript <<-END
#   tell application "Finder"
#     display dialog "Aloha"
#   end tell
# END

