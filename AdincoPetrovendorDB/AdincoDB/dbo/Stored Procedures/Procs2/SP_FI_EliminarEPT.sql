
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_EliminarEPT'
)
    DROP PROCEDURE SP_FI_EliminarEPT
GO
-- =============================================
-- Author:		Marcos Garcia
-- Create date: 15-02-2020
-- Description:	Validaciones del Estudio de Precio de Transfer
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EliminarEPT]
--[dbo].[SP_FI_ValidacionesEPT] 0,0,11   
@IdContrato INT, 
@IdUsuario  INT, 
@IdEPT      INT
AS
    BEGIN
        SET NOCOUNT ON;
        DELETE FROM dbo.FI_EstudioPreciosTransfer
        WHERE IdEstudioPrecioTransfer = @IdEPT;

        IF @@ERROR <> 0
            SELECT 'false' AS msj;
            ELSE
            SELECT 'true' AS msj;
    END;