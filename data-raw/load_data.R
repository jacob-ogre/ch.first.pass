# BSD_2_clause

# load the data

tabs <- list.files("data-raw/", pattern = "xlsx")
for(i in tabs) {
  fil <- paste0("data-raw/", i)
  cur_df <- stringr::str_replace(i, pattern = ".xlsx", replacement = "")
  dat <- readxl::read_excel(fil)
  dat$Species <- rep(cur_df, length(dat[,1]))
  assign(cur_df, dat, env = .GlobalEnv)
}

rm(cur_df)
rm(dat)
rm(fil)
rm(i)
rm(tabs)

lapply(ls(), FUN = function(x) {
  save(list = x, file = paste0("data-raw/", x, ".rda")) }
)

dfs <- Filter(function(x) is(x, "data.frame"), mget(ls()))
all_sp <- do.call(rbind, dfs)
names(all_sp) <- c("Count", "from_to", "Acres", "Species")

split <- stringr::str_split(all_sp$from_to, pattern = " to ")
all_sp$from <- unlist(lapply(split, `[`, 1))
all_sp$to <- unlist(lapply(split, `[`, 2))


devtools::use_data(all_sp, overwrite = TRUE)
