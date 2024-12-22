SELECT DISTINCT
    "SK_LOT",
    "NUMLOT",
    "DESLOT",
    "SITLOT"
FROM {{ ref('lancamentos') }}