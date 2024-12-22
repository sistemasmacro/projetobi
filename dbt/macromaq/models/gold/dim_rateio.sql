SELECT DISTINCT
    "SK_RAT",
    "SITRAT",
    "FILRAT",
    "TEMRAT"
FROM {{ ref('lancamentos') }}