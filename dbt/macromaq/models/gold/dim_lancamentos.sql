SELECT DISTINCT
    "SK_LCT",
    "NUMLCT",
    -- "DOCLCT",
    "NUMFTC",
    "TIPLCT",
    "ORILCT",
    "SITLCT",
    -- "CPLLCT",
    -- "OBSCPL",
    -- "INDLCT",
    -- "ECDLCT",
    -- "CTADEB",
    -- "CTACRE",
    -- "VLRLCT",
    -- "DATEXT",
    -- "IDEGED",
    -- "CTARED",
    -- "SITRAT",
    "DEBCRE"
    -- "CTAFIN"
FROM {{ ref('lancamentos') }}