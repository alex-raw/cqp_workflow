#!/usr/bin/env perl
use warnings;
use strict;


# subroutine to pass command as string to a headless cqp process and skip first
# line which contains version number; NOTE: check what your CQP version prints
# as first line and remove `| tail` if necessary
sub query_cqp {
    `echo \'${_[0]}\' | cqp -c | tail -n +2`; #'
}

# save CQP command(s) as string, cqp -e convenience features are off, e.g.,
# every statement has to be delimited with `;`
# `cat` has to be called explicitely
my $CQP_QUERY = <<"END";
    BNC-BABY;
    query = "test";
    cat query;
END

# can be saved directly as variable or array
my @CQP_CONC = query_cqp $CQP_QUERY;
print @CQP_CONC;

#---------------------------------------------------------------------
# `set PrettyPrint no` / `set pp no`
# takes care of most "clean-up" for count and group
my $CQP_QUERY_FREQS = <<"END";
    set PrettyPrint no;
    BNC-BABY;
    query=[class = "ADV"];
    count query by hw;
END

print query_cqp $CQP_QUERY_FREQS;

#---------------------------------------------------------------------
# automate to your heart's desire
foreach my $corpus ("BNC-BABY", "BROWN") {
    print query_cqp <<"    END";
        set PrettyPrint no;
        $corpus;
        query=[class = "ADV"];
        size query;
    END
}
