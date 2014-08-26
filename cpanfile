requires "Class::Method::ModifiersX::Augment" => "0.001";
requires "Date::Format" => "2.22";
requires "Encode" => "2.12";
requires "File::DataClass" => "v0.42.0";
requires "Moo" => "1.004002";
requires "Try::Tiny" => "0.18";
requires "Type::Tiny" => "0.030";
requires "Unexpected" => "v0.22.0";
requires "namespace::autoclean" => "0.19";
requires "perl" => "5.010001";

on 'build' => sub {
  requires "Module::Build" => "0.4004";
  requires "Test::Requires" => "0.06";
  requires "Text::Diff" => "1.37";
  requires "version" => "0.88";
};

on 'configure' => sub {
  requires "Module::Build" => "0.4004";
  requires "version" => "0.88";
};
