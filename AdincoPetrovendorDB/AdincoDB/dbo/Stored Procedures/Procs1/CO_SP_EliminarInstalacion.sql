-- =============================================
-- Author:		<Jose Roman>
-- Create date: <24-05-2018>
-- Description:	<Eliminado logico de una instalacion>
-- =============================================

CREATE procedure [dbo].[CO_SP_EliminarInstalacion]
	@IdInstalacion INT,
	@IdUsuario INT
AS
BEGIN
	UPDATE dbo.CO_Instalacion
		SET Activo = 0,
			IdUsuario = @IdUsuario,
			FecMovto = GETDATE()
		WHERE IdInstalacion = @IdInstalacion
END