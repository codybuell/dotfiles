#!/usr/bin/perl

use Purple;
use Data::Dumper;
%PLUGIN_INFO = (
    perl_api_version => 2,
    name => "OSX Notifications",
    version => "1.0",
    summary => "Use osx display notification for messages.",
    description => "Use osx display notification for messages.",
    author => "Bob Cavey & Cody Buell",
    url => "http://pidgin.im",
    load => "plugin_load",
    # prefs_info => "prefs_info_cb",
    unload => "plugin_unload"
);
sub prefs_info_cb {
    # Get all accounts to show in the drop-down menu
    @accounts = Purple::Accounts::get_all();

    $frame = Purple::PluginPref::Frame->new();

    # $acpref = Purple::PluginPref->new_with_name_and_label(
    #     "/plugins/core/url_shorten/max_url_length", "Max length for url: ");
    $acpref->set_bounds(10,100);

    $frame->add($acpref);

    return $frame;
}
sub plugin_init {
    return %PLUGIN_INFO;
}

sub received_im_msg_handler {
  my ($account, $sender, $message, $conv, $flags, $data) = @_;

  $message =~ s/<[^>]+>//g;

  my $buddy = Purple::Find::buddy($account, $sender);
  if ($buddy) {
    my $name = $buddy->get_name();
    my $alias = $buddy->get_alias();
    if ($name ne $alias) {
      $sender = "$alias ($name)";
    } else {
      $sender = "$name";
    }
  }

# system("lock_blink &");
# system("reattach-to-user-namespace osascript -e 'display notification \"$sender: $message\" with title \"Finch\" sound name \"Submarine\"'");
  system("reattach-to-user-namespace terminal-notifier -title \"$sender:\" -message \"$message\" -sender com.apple.Terminal -sound Purr");
}

sub received_chat_msg_handler {
  my ($account, $sender, $message, $conv, $flags, $data) = @_;

  $message =~ s/<[^>]+>//g;

  my $buddy = Purple::Find::buddy($account, $sender);
  if ($buddy) {
    my $name = $buddy->get_name();
    my $alias = $buddy->get_alias();
    if ($name ne $alias) {
      $sender = "$alias ($name)";
    } else {
      $sender = "$name";
    }
  }

  my $chatroom = $conv->get_title();

    if ($flags != "1026" && $flags != "1025" && $flags != "1") {
#     system("reattach-to-user-namespace osascript -e 'display notification \"[$chatroom] $sender: $message\" with title \"Finch\" sound name \"Ping\"'");
      system("reattach-to-user-namespace terminal-notifier -title \"[$chatroom] $sender:\" -message \"$message\" -sender com.apple.Terminal -sound Purr");
    }
}

sub plugin_load {
    my $plugin = shift;
    Purple::Debug::info("osxnotifications", "OSX Notifications $PLUGIN_INFO{version} Loaded.\n");
    # A pointer to the handle to which the signal belongs
    my $convs_handle = Purple::Conversations::get_handle();

    Purple::Signal::connect(Purple::Conversations::get_handle(),
      "received-im-msg", $plugin, \&received_im_msg_handler, 0);
    Purple::Signal::connect(Purple::Conversations::get_handle(),
      "received-chat-msg", $plugin, \&received_chat_msg_handler, 0);
}
sub plugin_unload {
    my $plugin = shift;
    Purple::Debug::info("osxnotifications", "OSX Notifications $PLUGIN_INFO{version} Unloaded.\n");
}
