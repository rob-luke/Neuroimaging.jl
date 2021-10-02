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
    )

    register(
        DataDep(
            "BioSemi64Locations",
            "ELP containing location of 64 channel biosemi sensors",
            [
                "https://raw.githubusercontent.com/rob-luke/NeuroimagingFiles/main/biosemi64.elp",
            ],
        ),
    )
end
