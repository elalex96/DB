-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
-- Alter Author:        Neri del Angel
-- Alter Date:			17 de Mayo del 2023
-- Alter Description:	Se ajusta temas de espacios al buscar la moneda en VU_MonedaXML
--						Se agrego la búsqueda en PV_TipoMoneda en caso de que no se llegase a encontrar en la tabla VU_MonedaXML
--						la moneda ya sea por TipoMoneda o TipoMonedaCorto, si se registra nueva moneda regresa el id de la moneda y no el identity de VU_MonedaXML
-- =============================================  
CREATE PROCEDURE [dbo].[sp_VU_ObtenIdMoneda] 
	@moneda NVARCHAR(100)
AS
BEGIN    
    SET NOCOUNT ON;

	DECLARE @ENCONTRADOS AS INT,
            @MonedaPorDefecto AS INT = 1 --MXN

    SELECT @ENCONTRADOS = COUNT(*)
    FROM VU_MonedaXML (NOLOCK)
    WHERE RTRIM(LTRIM(UPPER(NombreMonedaXML))) = RTRIM(LTRIM(UPPER(ISNULL(@moneda,''))))

    IF (@ENCONTRADOS > 0)
        SELECT TOP 1 IdMoneda AS ID,
               NombreMonedaXML AS MSG
        FROM VU_MonedaXML (NOLOCK)
        WHERE RTRIM(LTRIM(UPPER(NombreMonedaXML))) = RTRIM(LTRIM(UPPER(ISNULL(@moneda,''))))
    ELSE
    BEGIN

        SELECT @ENCONTRADOS = COUNT(*)
        FROM PV_TipoMoneda (NOLOCK)
        WHERE (
                  RTRIM(LTRIM(UPPER(TipoMoneda))) = RTRIM(LTRIM(UPPER(ISNULL(@moneda,''))))
                  OR RTRIM(LTRIM(UPPER(TipoMonedaCorto))) = RTRIM(LTRIM(UPPER(ISNULL(@moneda,''))))
              )

        IF (@ENCONTRADOS > 0)
            SELECT TOP 1
                @MonedaPorDefecto = IdMoneda
            FROM PV_TipoMoneda (NOLOCK)
            WHERE (
                      RTRIM(LTRIM(UPPER(TipoMoneda))) = RTRIM(LTRIM(UPPER(ISNULL(@moneda,''))))
                      OR RTRIM(LTRIM(UPPER(TipoMonedaCorto))) = RTRIM(LTRIM(UPPER(ISNULL(@moneda,''))))
                  )

        INSERT INTO [dbo].[VU_MonedaXML]
        (
            [NombreMonedaXML],
            [IdMoneda]
        )
        VALUES
        (RTRIM(LTRIM(ISNULL(@moneda, ''))), @MonedaPorDefecto)

        SELECT @MonedaPorDefecto AS ID,
               RTRIM(LTRIM(ISNULL(@moneda, ''))) AS MSG
    END
END
