#!/usr/bin/env python

# Possibly an alternative:
# pip install cwb-ccc
#
# from ccc import Corpora ...
#
# https://github.com/ausgerechnet/cwb-ccc#installation
# didn't manage to install on my system

import subprocess
import pandas as pd

# function to pass command as string to a headless cqp process
# and read into a pandas data.frame
# set `skiprows` to 0 if your version of CQP doesn't print the version nr.
def query_cqp(
    query,
    header=None,
    sep="\s+",     # or \t+ depending on output
    quoting=3,   # disable quoting
    skiprows=1,
    **kwargs
):
    cmd = f"echo '{query}' | cqp -c"
    with subprocess.Popen(cmd, shell=True, stdout = subprocess.PIPE) as proc:
        return pd.read_table(
            proc.stdout,
            header=header,
            sep=sep,
            quoting=quoting,
            skiprows=skiprows,
            **kwargs
        )

  # if "CQP version" in out[0]:
  #   return(out[-1]) else return(out)


# save CQP command(s) as string, cqp -e convenience features are off, e.g.,
# every statement has to be delimited with `;`
# `cat` is not called implicitely (in non-interactive mode `tabulate` is
# preferable to cat)
query = """
  BROWN;
  query = "test";
  tabulate Last match[-5]..match[5] word;
"""

concordance = query_cqp(query)
print(concordance)

each_corpus = lambda corpus : f"""
    {corpus};
    query = "test";
    tabulate Last match[-5]..match[5] word;
"""

corpora = ("BNC-BABY", "BROWN")
queries = map(each_corpus, corpora)
concordances = map(query_cqp, queries)

for conc in concordances:
    print(conc[:15])

# get counts of `hw` for BNC, and `lemma` for BROWN
corpora = ("BNC-BABY", "BROWN")
p_attrs = ("hw", "lemma")

each_corpus_lemma = lambda corpus, p_attr : f"""
    set PrettyPrint no;
    {corpus};
    query=[class = "ADV"];
    count query by {p_attr};
"""

queries = map(each_corpus_lemma, corpora, p_attrs)

# `usecols` to skip offset (2nd column in count output)
frequency_lists = (query_cqp(
    query,
    usecols=[0, 2],
    names = ["f", "type"]
) for query in queries)

for corpus, freq in zip(corpora, frequency_lists):
    print(f"corpus: {corpus}\n", freq[:15], "\n")



# In older versions without f-strings, the lambdas look like this:
# each_corpus = lambda corpus : """
#     %s;
#     query = "test";
#     tabulate Last match[-5]..match[5] word;
# """ % corpus

# each_corpus_lemma = lambda corpus, p_attr : """
#     set PrettyPrint no;
#     %s;
#     query=[class = "ADV"];
#     count query by %s;
# """ % (corpus, p_attr)

