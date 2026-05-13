USE [Petrovendor]
GO
IF EXISTS
(
	SELECT 1
	FROM dbo.sysobjects
	WHERE name = 'SP_AD_EliminarIteracionM'
)
	DROP PROCEDURE SP_AD_EliminarIteracionM;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Modified date: 05/05/2026
-- Description:	Se agrega auditoria de usuario al borrado logico de iteraciones.
-- =============================================
CREATE PROCEDURE SP_AD_EliminarIteracionM
	-- Add the parameters for the stored procedure here
	@IdIteracion INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.RegistroIteraciones
	SET IsEliminado = 1,
		ModificadoPor = @IdUsuario,
		ModificadoEl = GETDATE()
	WHERE IdIteracion = @IdIteracion
END
