USE [Petrovendor]
GO
IF EXISTS
(
	SELECT 1
	FROM dbo.sysobjects
	WHERE name = 'SP_AD_InsertarVersionIteracion'
)
	DROP PROCEDURE SP_AD_InsertarVersionIteracion;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Modified date: 05/05/2026
-- Description:	Se agrega auditoria de usuario al alta de iteraciones.
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_InsertarVersionIteracion]
	-- Add the parameters for the stored procedure here
	@version NVARCHAR(MAX),
	@modulo NVARCHAR(MAX),
	@icono NVARCHAR(MAX),
	@versionactual BIT,
	@aplicacion NVARCHAR(MAX),
	@tipoactualizacion NVARCHAR(MAX),
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.RegistroIteraciones
	(
	    VersionIteracion,
	    Modulo,
	    IconoModulo,
	    FechaRegistro,
		CreadoPor,
	    VersionActual,
		Aplicacion,
		TipoActualizacion
	)
	VALUES
	(   @version,       -- VersionIteracion - nvarchar(50)
	    @modulo,       -- Modulo - nvarchar(max)
	    @icono,       -- IconoModulo - nvarchar(max)
	    GETDATE(), -- FechaRegistro - datetime
		@IdUsuario,
	    @versionactual,       -- VersionActual - bit
	    @aplicacion,
		@tipoactualizacion
		)

		SELECT @@IDENTITY
END
