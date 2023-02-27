# function to pass command as string to a headless cqp process and skip first
# line if it contains version number
query_cqp <- function(query) {
  out <- system2("echo",
    paste("'", query, "'", "| cqp -c"),
    stdout = TRUE
  )
  if (grepl("CQP version", out[1]))
    return(out[-1]) else return(out)
}

# save CQP command(s) as string, cqp -e convenience features are off, e.g.,
# every statement has to be delimited with `;`
# `cat` has to be called explicitely
query <- r"(
  BROWN;
  query = "test";
  tabulate Last match[-5]..match[5] word;
)"

# can be saved directly as variable or array
concordance <- query_cqp(query)
concordance

# save as data.frame
read.table(text = query_cqp(query), sep = " ", quote = "")
# TODO: cwbwrapr

# automation with string interpolation by `glue` library
library(glue)
library(cwbwrapr)

corpora <- c("BNC-BABY", "BROWN")

concordances <- lapply(corpora, \(corpus) {
    query <- glue(r"(
      {corpus};
      query = "test";
      tabulate Last match[-5]..match[5] word;
    )")
    query_cqp(query)
})

# get counts of `hw` for BNC, and `lemma` for BROWN
corpora <- c("BNC-BABY", "BROWN")
p_attrs <- c("hw", "lemma")

frequency_lists <- mapply(\(corpus, p_attr) {
    query <- glue(r"(
      set PrettyPrint no;
      {corpus};
      query=[class = "ADV"];
      count query by {p_attr};
    )")
    out <- query_cqp(query)
    cwbwrapr::read_freqs(text = out) # FIXME: path is missing
}, corpora, p_attrs)
