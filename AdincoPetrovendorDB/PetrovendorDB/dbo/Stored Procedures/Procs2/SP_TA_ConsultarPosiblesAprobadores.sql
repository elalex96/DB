use petrovendor
go
drop proc if exists SP_TA_ConsultarPosiblesAprobadores
go
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 31-03-17
-- Description:	 Consultar Aprobadores recibiendo el IdOperador y IdProveedor
-- =============================================
-- Author:		David
-- Create date: marzo 31 24
-- Description:	Se optimiza sp Issue #2686 petrovendor
-- =============================================
CREATE  PROCEDURE [dbo].[SP_TA_ConsultarPosiblesAprobadores] 
	-- Add the parameters for the stored procedure here
	@IdOperacion INT,
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DROP TABLE if exists #UsuariosExcluidos	
	CREATE TABLE #UsuariosExcluidos (
		IdUsuario INT
	)

	INSERT INTO #UsuariosExcluidos (IdUsuario)
	SELECT T.IdAprobador
	FROM TA_Tarea AS T 
	INNER JOIN TA_TareaOperacion AS TTO ON T.IdTarea = TTO.IdTarea
	INNER JOIN TA_Operacion AS TOO ON TTO.IdOperacion = TOO.IdOperacion
	WHERE TOO.IdOperacion = @IdOperacion


	INSERT INTO #UsuariosExcluidos (IdUsuario)
	SELECT TOO.IdAsignador
	FROM TA_Operacion AS TOO
	WHERE IdOperacion = @IdOperacion

	SELECT U.IdUsuario AS IdUsuario, Nombre +'/'+ TU.NombreTipoUsuario AS DetalleUsuario
	FROM S_Usuario AS U
	INNER JOIN S_TipoUsuario AS TU ON U.IdTipoUsuario = TU.IdTipoUsuario
	INNER JOIN S_UsuarioProveedor AS UP ON U.IdUsuario = UP.IdUsuario
	INNER JOIN S_Proveedor AS P ON UP.IdProveedor = P.IdProveedor
	INNER JOIN S_UsuarioRol AS UR ON U.IdUsuario = UR.IdUsuario 
	INNER JOIN S_ROL AS R ON UR.IdRol = R.IdRol
	LEFT JOIN #UsuariosExcluidos UE ON U.IdUsuario = UE.IdUsuario
	WHERE U.Activo = 1 AND P.IdProveedor = @IdProveedor AND R.IdRol = 1 AND UR.Activo = 1
	AND UE.IdUsuario IS NULL
		
END
