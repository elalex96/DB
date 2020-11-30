-- =============================================
-- Author:		<Jose Roman>
-- Create date: <14/05/2018>
-- Description:	<Consulta de oficios por contrato, muestra sus relaciones>
-- =============================================

create PROCEDURE OF_SP_ConsultaPermisosPorUsuario
	@IdUsuario INT,
	@IdContrato INT
AS
BEGIN
	SELECT ISNULL(Creacion, 0),
			ISNULL(Revision, 0),
		 	ISNULL(Modificacion, 0),
			ISNULL(Aprobacion, 0),
			ISNULL(Firma, 0)
	FROM dbo.OF_PermisosUsuario
	WHERE IdUsuario = @IdUsuario
		AND IdContrato = @IdContrato
END