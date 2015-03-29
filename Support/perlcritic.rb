# rubocop:disable Style/AsciiComments, Style/HashSyntax

# Analyze the current file with Perl-Critic.
#
# Authors:: Guillaume Carbonneau
#           Matt Foster
#           René Schwaiger (sanssecours@f-m.fm)

# -- Imports -------------------------------------------------------------------

require ENV['TM_SUPPORT_PATH'] + '/lib/escape'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/executor'

# -- Functions -----------------------------------------------------------------

# Format a single line of output from +perlcritic+.
#
# = Arguments
#
# [line] A single line of output produced by +perlcritic+
# [show_reference] A boolean value that specifies if the output should include
#                  references to the matching section of the book “Perl Best
#                  Practices” (PBP).
#
# = Output
#
# The function returns a string containing HTML code.
def format_critic_output(line, show_reference)
  return 'No problems found — Yay!' if line.chomp.end_with?('source OK')
  styles = { 5 => 'Red', 4 => 'GoldenRod', 3 => 'DodgerBlue' }
  styles.default = ''
  file, line_number, column, message, reference, severity = line.split(':')
  link = "txmt://open?url=file://#{e_url file}&amp;line=#{line_number}" \
         "&amp;column=#{column}"
  "<span class='out' style='color:#{styles[severity.to_i]};'>
      (Severity: #{severity.to_i})</span> #{message}
   <a href='#{link}'>at line #{line_number}, column #{column}</a>.
   #{reference + '.' if show_reference}<br />"
end

# Output an HMTL formatted analysis of the current Perl file by +perlcritic+.
def perl_critic
  show_reference = ENV['TM_PERLCRITIC_REFERENCE'] ? true : false
  TextMate::Executor.run(
    ENV['TM_PERLCRITIC'] || 'perlcritic', '--verbose', '%f:%l:%c:%m:%e:%s\n',
    ENV['TM_PERLCRITIC_LEVEL'] || '--stern', '--nocolor', ENV['TM_FILEPATH'],
    :use_hashbang => false, :verb => 'Criticizing') do |line, type|
    case type
    when :err then "<span class='err'>#{htmlize(line)}</span>"
    when :out then format_critic_output(line, show_reference)
    end
  end
end
