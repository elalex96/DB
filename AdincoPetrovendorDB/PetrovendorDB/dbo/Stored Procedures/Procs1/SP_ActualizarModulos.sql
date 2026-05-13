USE [Petrovendor]
GO
IF EXISTS
(
	SELECT 1
	FROM dbo.sysobjects
	WHERE name = 'SP_ActualizarModulos'
)
	DROP PROCEDURE SP_ActualizarModulos;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Abel Rivera
-- Create date: ABRIL
-- Description:	<Description,,>
-- =============================================
-- =============================================
-- Author:		Daniel AC 
-- Create date: 05/05/2026
-- Description:	Se agrega información de auditoria
-- =============================================
CREATE PROCEDURE [dbo].[SP_ActualizarModulos]
@IdModulo int,
@NombreModulo nvarchar(200),
@StringModuloId nvarchar(200),
@URL_MODULO nvarchar(350),
@IdUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE Modulo
	SET
	NombreModulo = @NombreModulo,
		StringModuloId = @StringModuloId,
		URL_MODULO = @URL_MODULO,
		ModificadoPor = @IdUsuario,
		ModificadoEl = GETDATE()
	WHERE IdModulo = @IdModulo


END

