SELECT DISTINCT
    "SK_CTA",
    "CTARED",
    "DESCTA",
    "ABRCTA",
    "CLACTA"
FROM {{ ref('lancamentos') }}