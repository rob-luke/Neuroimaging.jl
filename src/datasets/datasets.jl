function __init__()
    register(
        DataDep(
            "BioSemiTestFiles",
            "Manafacturer provided example files",
            ["https://www.biosemi.com/download/BDFtestfiles.zip"];
            post_fetch_method = [file -> run(`unzip $file`)],
        ),
    )
    register(
        DataDep(
            "ExampleSSR",
            "Steady state response data with few channels",
            [
                "https://github.com/rob-luke/Neuroimaging.jl-example-data/archive/refs/heads/master.zip",
            ];
            post_fetch_method = [file -> run(`unzip $file`)],
        ),
    ),
    register(
        DataDep(
            "LIMO dataset subject 1",
            "Face Experiment with continuous predictor",
            ["https://files.de-1.osf.io/v1/resources/52rea/providers/osfstorage/5cde823c8d6e050018595862/?zip="];
            post_fetch_method = [file -> run(`unzip $file`)],
        )
    )
end
