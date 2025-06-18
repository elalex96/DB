USE [Petrovendor]
GO
DROP PROCEDURE IF EXISTS USP_UPD_PV_ActulizarConfiguracionPorOperadora
/****** Object:  StoredProcedure [dbo].[USP_UPD_PV_ActulizarConfiguracionPorOperadora]    Script Date: 04/06/2025 09:50:00 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 04/06/2025
-- Description: actualizacion de configuracion por operadora
-- =============================================
CREATE PROCEDURE [dbo].[USP_UPD_PV_ActulizarConfiguracionPorOperadora]
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdUsuario INT,
	@Activo INT,
	@IdConfiguracionProveedoresOperadoras INT,
	@Descripcion nvarchar(max),
	@TipoConfiguracion NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE PV_ConfiguracionProveedoresOperadoras
	SET Activo = @Activo,
		IdContrato = @IdContrato,
		TipoConfiguracion = @TipoConfiguracion,
		Descripcion = @Descripcion
	WHERE IdConfiguracionProveedoresOperadoras = @IdConfiguracionProveedoresOperadoras;

END
