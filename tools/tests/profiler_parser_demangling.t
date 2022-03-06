#!/usr/bin/perl
#
# Tests for demangling native symbols.
# Copyright (C) 2020-2022 LuaVela Authors. See Copyright Notice in COPYRIGHT
# Copyright (C) 2015-2020 IPONWEB Ltd. See Copyright Notice in COPYRIGHT

use 5.010;
use warnings;
use strict;

# for in-source runs
use lib '../../tests/impl/uJIT-tests-Lua/suite/lib';

use UJit::Test;
use Cwd;

my $cwd        = Cwd::cwd();
my $tools_dir  = $ENV{TOOLS_BIN_DIR} // "$cwd/..";
my $chunks_dir = $ENV{CHUNKS_DIR} // "$tools_dir/tests/chunks";

my $tester = UJit::Test->new(
    tools_dir => $tools_dir,
    chunks_dir => $chunks_dir
);

my $out_dir = $tester->dir('profile_parser_demangling');
my $fname_stub = "$out_dir/profile.bin";

$tester->run('payload.lua', lua_args => $fname_stub)->exit_ok;

my $fname_real = (glob("$fname_stub*"))[0];

# If nothing is broken, there should be no unresolved native symbols in the
# output for the profiled payload script. This script is written to avoid
# potential problematic corner cases such as VDSO.
$tester->run_tool(UJit::Test::PROF_PARSER,
    'demangling',
    args => "--profile $fname_real")
    ->exit_ok
    ->stdout_has(' @ ')
    ->stdout_has_no('not_found @ 0x')
;
