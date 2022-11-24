
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180924
-- Description:	Verifica el tipo de contrato 
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_TipoContrato]--10041,2
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN

    SET NOCOUNT ON;
    SELECT --dbo.CO_Contrato.IdTipoContrato TipoContrato,
           CASE CO_Contrato.IdTipoContrato
               WHEN 2 THEN
                  CO_Contrato.IdTipoContrato
               WHEN 3 THEN
                   CASE IsConsorcio
                       WHEN 0 THEN
                           IsConsorcio
                       ELSE
                           3
                   END
           END AS 'IdTipoContrato'
    FROM dbo.CO_Contrato
        JOIN dbo.CO_TipoContrato
            ON CO_TipoContrato.IdTipoContrato = CO_Contrato.IdTipoContrato
    WHERE IdContrato = @IdContrato;

END;

