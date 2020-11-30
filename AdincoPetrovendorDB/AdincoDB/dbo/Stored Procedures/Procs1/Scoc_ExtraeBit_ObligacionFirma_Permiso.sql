
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 28/01/198
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[Scoc_ExtraeBit_ObligacionFirma_Permiso]
    @idUsuario  INT,
    @idContrato INT,
    @idPermiso  INT
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT
            FirmaObligatoria
        FROM
            dbo.AP_Permiso
        WHERE
            IdPermiso = @idPermiso;
    END;
