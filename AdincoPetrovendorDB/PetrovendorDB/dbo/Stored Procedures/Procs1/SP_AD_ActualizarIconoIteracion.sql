
USE [Petrovendor]
GO
IF EXISTS
(
	SELECT 1
	FROM dbo.sysobjects
	WHERE name = 'SP_AD_ActualizarIconoIteracion'
)
	DROP PROCEDURE SP_AD_ActualizarIconoIteracion;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Modified date: 06/05/2026
-- Description:	Actualiza el icono y la version actual de la iteracion, registrando auditoria de modificacion.
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ActualizarIconoIteracion]
	-- Add the parameters for the stored procedure here
	@version INT,
	@icono NVARCHAR(MAX),
	@versioncatual BIT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @versions NVARCHAR(MAX) = (CAST(@version AS NVARCHAR(MAX)))
    -- Insert statements for procedure here
	UPDATE dbo.RegistroIteraciones
	SET IconoModulo = @icono,
		VersionActual = @versioncatual,
		ModificadoPor = @IdUsuario,
		ModificadoEl = GETDATE()
	WHERE IdIteracion = @version

	SELECT @icono
END

