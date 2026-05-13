USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es asi, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[SP_AD_ActualizarURL];
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Modified:    Agregar auditoría ModificadoPor/ModificadoEl
-- Description:	Actualiza la URL del dominio y registra
--              quién realizó la modificación.
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ActualizarURL]
    @IdDominio    INT,
    @Url          NVARCHAR(MAX),
    @ModificadoPor INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.TA_Dominios
    SET Url          = @Url,
        ModificadoPor = @ModificadoPor,
        ModificadoEl  = GETDATE()
    WHERE IdDominio = @IdDominio;
END
GO