register(
    DataDep(
        "BioSemiTestFiles",
        "Manafacturer provided example files",
        ["https://www.biosemi.com/download/BDFtestfiles.zip"];
        post_fetch_method = [file -> run(`unzip $file`)],
    ),
)
