-- =============================================
-- Author:		DANIEL AC 
-- Create date: 05/08/2018
-- Description:	CAMBIO ED S_DOCUMENTO A S_DOCUMENTO_S3
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarDocumentosCargadosTemporal] @IdDocumento INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @ExisteDoc INT;
    SET @ExisteDoc =
    (
        SELECT COUNT(IdTipoDocumento)
        FROM dbo.S_Documento_S3
        WHERE IdDocumento = @IdDocumento
              AND IdTipoValidacionDocumento = 4
    );
    IF @ExisteDoc > 0
    BEGIN
        SELECT 'Sin documento';
    END;
    ELSE
    BEGIN
        SELECT 'otro';
    END;

END;