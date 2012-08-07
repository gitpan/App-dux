
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Run Data::Unixish function on the command-line",
  "dist_author" => [
    "Steven Haryanto <stevenharyanto\@gmail.com>"
  ],
  "dist_name" => "App-dux",
  "dist_version" => "1.24",
  "license" => "perl",
  "module_name" => "App::dux",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Data::Unixish" => 0,
    "Perinci::CmdLine" => "0.53",
    "Tie::Diamond" => "0.03",
    "perl" => "5.010000"
  },
  "script_files" => [
    "bin/dux"
  ]
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
