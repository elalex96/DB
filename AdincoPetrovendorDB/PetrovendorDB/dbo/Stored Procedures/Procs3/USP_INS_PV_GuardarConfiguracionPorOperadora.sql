USE [Petrovendor]
GO
DROP PROCEDURE IF EXISTS USP_INS_PV_GuardarConfiguracionPorOperadora
/****** Object:  StoredProcedure [dbo].[USP_INS_PV_GuardarConfiguracionPorOperadora]    Script Date: 04/06/2025 09:49:19 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 04/06/2024
-- Description: guardar configuracion por operadora
-- =============================================
CREATE PROCEDURE [dbo].[USP_INS_PV_GuardarConfiguracionPorOperadora]
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdUsuario INT,
	@Descripcion nvarchar(max),
	@TipoConfiguracion NVARCHAR(100)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO PV_ConfiguracionProveedoresOperadoras
	(
		TipoConfiguracion,
		Descripcion,
		IdContrato,
		Operadora,
		Proveedor,
		Activo,
		CreadoEl
	)
		VALUES
	(
		@TipoConfiguracion,
		@Descripcion,
		@IdContrato,
		1,
		0,
		1,
		GETDATE()
	);

	SELECT SCOPE_IDENTITY();

END
