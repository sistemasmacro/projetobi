SELECT DISTINCT
    "SK_CCU",
    -- "CODEMP",
    "CODCCU",
    "DESCCU",
    "ABRCCU",
    "TIPCCU",
    "MSKCCU",
    "CCUPAI",
    "GRUCCU",
    "NIVCCU",
    "POSCCU",
    "ANASIN"
FROM {{ ref('lancamentos') }}