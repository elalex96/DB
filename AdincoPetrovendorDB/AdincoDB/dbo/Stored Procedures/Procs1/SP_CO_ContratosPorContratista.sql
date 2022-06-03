-- =============================================
-- Author:		Marcos Garcia
-- Create date: 05-12-2019
-- Description:	Selecciona los Contratos por Contratista
-- =============================================
-- Modification Author:	Neri del Angel
-- Modification Date:	02 de Junio del 2022
-- Description:			Optimizacion de PROCEDURE por temas de error marcado 
--						[Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding.]
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ContratosPorContratista]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    --======Seleccion del Contratista=========
    DECLARE @IdContratista INT;
    SELECT TOP 1
        @IdContratista = IdContratista
    FROM dbo.CO_Contrato (NOLOCK)
    WHERE IdContrato = @IdContrato;
    --=======Contratos con el mismo Contratista========
    --Solo Para Jaguar
    IF (@IdContratista = 10005 OR @IdContratista = 10006)
    BEGIN
        SELECT IdContrato,
               NumeroContrato
        FROM dbo.CO_Contrato (NOLOCK)
        WHERE IdContratista IN ( 10005, 10006 )
              AND Activo = 1;
    END;
    ELSE
    BEGIN
        SELECT IdContrato,
               NumeroContrato
        FROM dbo.CO_Contrato (NOLOCK)
        WHERE IdContratista = @IdContratista
              AND Activo = 1;
    END;
END;