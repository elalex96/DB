IF EXISTS (
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_SC_Unidades_Cmb'
)
    DROP PROCEDURE [dbo].[p_SC_Unidades_Cmb]
GO

CREATE PROCEDURE [dbo].[p_SC_Unidades_Cmb]
AS
BEGIN
    SELECT
        IdUnidad,
        Unidad,
        UMB
    FROM
        PV_MM_MaterialUnidad WITH (NOLOCK)
    WHERE
        IsActivo = 1
END
