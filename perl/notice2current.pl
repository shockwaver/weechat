# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# This script will send server notices to the currently active buffer
use strict;
use warnings;

my %SCRIPT = (
	name => 'notice2current',
	author => 'shockwaver',
	version => '1.0',
	license => 'GPL3',
	desc => 'Sends server notices to currently active buffer.',
	opt => 'plugins.var.perl'
);

my %OPTIONS_DEFAULT = (
	'debug' => ['0', 'Debug Mode'],
);

my %OPTIONS = ();

# Register the script and initialize
weechat::register($SCRIPT{"name"}, $SCRIPT{"author"}, $SCRIPT{"version"}, $SCRIPT{"license"}, $SCRIPT{"desc"}, "", "");
init_config();

#
# Handle config stuff
#
sub init_config
{
        weechat::hook_config("$SCRIPT{'opt'}.$SCRIPT{'name'}.*", "config_cb", "");
        my $version = weechat::info_get("version_number", "") || 0;
        foreach my $option (keys %OPTIONS_DEFAULT) {
                if (!weechat::config_is_set_plugin($option)) {
                        weechat::config_set_plugin($option, $OPTIONS_DEFAULT{$option}[0]);
                        $OPTIONS{$option} = $OPTIONS_DEFAULT{$option}[0];
                } else {
                        $OPTIONS{$option} = weechat::config_get_plugin($option);
                }
        }
		
		debug("Initializing");
		handle_hooks();
}
sub config_cb
{
        my ($pointer, $name, $value) = @_;
        $name = substr($name, length("$SCRIPT{opt}.$SCRIPT{name}."), length($name));
        $OPTIONS{$name} = $value;
        return weechat::WEECHAT_RC_OK;
}
sub handle_hooks
{
	debug("Hooking to print");
	weechat::hook_print("", "irc_notice", "", 0, "notice_cb", "");
}

sub debug {
	#my ($pointer, $debug_msg) = @_;
	#weechat::print("", "@_");
	if ($OPTIONS{debug} eq "1") {
		weechat::print("", "[$SCRIPT{name}]: @_");
	}
}

sub notice_cb {
	my ($data, $buffer, $date, $tags, $displayed, $highlight, $prefix, $message) = @_;
	debug("Data: $data");
	debug("buffer: $buffer");
	debug("tags: $tags");
	debug("prefix: $prefix");
	debug("message: $message");
	
	my $current_buffer = weechat::current_buffer();
	
	# Don't send to current buffer if already going there
	if ($buffer eq $current_buffer) {
		return weechat::WEECHAT_RC_OK;
	}
	my $color = weechat::color("red");
	my $reset = weechat::color("reset");
	weechat::print($current_buffer, "\t\t$color [Notice]$reset $prefix $message");
	return weechat::WEECHAT_RC_OK;
}




