USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es asi, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[SP_AD_ActualizarCorreo];
GO
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 23-03-17
-- Modified Author:	Alexander Gomez
-- Modified date: 04-05-2026
-- Modified:    Agregar auditoría ModificadoPor/ModificadoEl
-- Description:	Actualiza la plantilla de correo y registra
--              quién realizó la modificación.
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ActualizarCorreo]
    @IdCorreo     INT,
    @Asunto       NVARCHAR(500),
    @Descripcion  NVARCHAR(500),
    @HTML         NVARCHAR(MAX),
    @IdServidor   INT,
    @ModificadoPor INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.TA_Correo
    SET HTML         = @HTML,
        Asunto       = @Asunto,
        Descripcion  = @Descripcion,
        IdServidor   = @IdServidor,
        ModificadoPor = @ModificadoPor,
        ModificadoEl  = GETDATE()
    WHERE IdCorreo = @IdCorreo;
END
GO