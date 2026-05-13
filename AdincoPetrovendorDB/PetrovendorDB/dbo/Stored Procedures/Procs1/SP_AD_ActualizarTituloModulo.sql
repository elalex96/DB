USE [Petrovendor]
GO
IF EXISTS
(
	SELECT 1
	FROM dbo.sysobjects
	WHERE name = 'SP_AD_ActualizarTituloModulo'
)
	DROP PROCEDURE SP_AD_ActualizarTituloModulo;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Modified date: 05/05/2026
-- Description:	Actualiza el titulo y subtitulo y registra la auditoria de modificacion en Titulos.
-- =============================================
CREATE PROCEDURE SP_AD_ActualizarTituloModulo
    -- Add the parameters for the stored procedure here
    @IdTitulosModulo INT,
    @NombreTitulo NVARCHAR(MAX),
    @NombreSubtitulo NVARCHAR(MAX),
    @IdUsuario INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;



    -- Insert statements for procedure here
    UPDATE T
    SET T.NombreTitulo = @NombreTitulo,
        T.NombreSubtitulo = @NombreSubtitulo,
        T.ModificadoPor = @IdUsuario,
        T.ModificadoEl = GETDATE()
    FROM Titulos T
        INNER JOIN dbo.TituloModulo AS TM
            ON TM.IdTitulo = T.IdTitulo
    WHERE TM.IdTitulosModulo = @IdTitulosModulo

END
