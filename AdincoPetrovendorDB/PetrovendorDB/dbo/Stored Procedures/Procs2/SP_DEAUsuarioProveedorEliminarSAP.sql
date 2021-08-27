USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_DEAUsuarios]    Script Date: 26/08/2021 12:42:33 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 25/08/2021
-- Description:	Eliminacion lógica de usuario o proveedor SAP
-- =============================================
CREATE PROCEDURE SP_DEAUsuarioProveedorEliminarSAP
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario INT,
@IdProveedorDescripcionSAP INT = 0,
@IdUsuarioSolicitanteSAP INT = 0

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@IdProveedorDescripcionSAP<>0)
	BEGIN
		UPDATE [dbo].[DEA_ProveedorDescripcionSAP]
		SET IsEliminado = 1,
		ModificadoEn = GETDATE(),
		ModificadoPor = @IdUsuario
		WHERE IdProveedorDescripcionSAP = @IdProveedorDescripcionSAP
	END
	IF(@IdUsuarioSolicitanteSAP<>0)
	BEGIN
		UPDATE [dbo].[DEA_UsuarioSolicitanteSAP]
		SET IsEliminado = 1,
		ModificadoEn = GETDATE(),
		ModificadoPor = @IdUsuario
		WHERE IdUsuarioSolicitanteSAP = @IdUsuarioSolicitanteSAP
	END

	IF @@ERROR <> 0
		SELECT 'false' AS msj;
		ELSE
	SELECT 'true' AS msj;
END
GO