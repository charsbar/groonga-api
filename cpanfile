requires 'Exporter' => 0;
requires 'JSON::XS' => 0;
requires 'Path::Tiny' => 0;

on test => sub {
  requires 'Test::Differences' => 0;
  requires 'Test::More' => '0.88';
  requires 'Test::UseAllModules' => '0.10';
  requires 'version' => '0.77';
};
