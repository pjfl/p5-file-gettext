requires "Date::Format" => "2.24";
requires "Encode" => "2.67";
requires "File::DataClass" => "v0.61.0";
requires "Moo" => "2.000001";
requires "Try::Tiny" => "0.22";
requires "Type::Tiny" => "1.000002";
requires "Unexpected" => "v0.38.0";
requires "namespace::autoclean" => "0.22";
requires "perl" => "5.010001";

on 'build' => sub {
  requires "Hash::MoreUtils" => "0.05";
  requires "Module::Build" => "0.4004";
  requires "Test::Requires" => "0.06";
  requires "Text::Diff" => "1.37";
  requires "version" => "0.88";
};

on 'configure' => sub {
  requires "Module::Build" => "0.4004";
  requires "version" => "0.88";
};
