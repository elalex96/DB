-- =============================================
-- Author:		Pedro Acuña
-- Create date: 23/03/2018
-- Description:	 Obtener el numero de aprobadores que se pueden reasignar en esta tarea
-- =============================================
CREATE  PROCEDURE [dbo].[SP_TA_CuentaPosiblesAprobadores] 
	@IdOperacion INT,
	@IdProveedor INT
AS
BEGIN
	SET NOCOUNT ON;

     SELECT COUNT(*)
	 FROM S_Usuario AS U
	 INNER JOIN S_TipoUsuario AS TU ON TU.IdTipoUsuario=U.IdTipoUsuario
	 INNER JOIN S_UsuarioProveedor AS UP ON UP.IdUsuario=U.IdUsuario
	 INNER JOIN S_Proveedor  AS P on P.IdProveedor = UP.IdProveedor
	 INNER JOIN S_UsuarioRol AS UR ON UR.IdUsuario = U.IdUsuario
	 INNER JOIN S_ROL AS R ON R.IdRol = UR.IdRol  
	 WHERE  U.Activo=1 AND P.IdProveedor = @IdProveedor  AND R.IdRol =1 AND UR.Activo = 1
	 AND NOT  U.IdUsuario IN (SELECT T.IdAprobador
							  FROM TA_Tarea AS T 
							  INNER JOIN TA_TareaOperacion AS TTO ON TTO.IdTarea=T.IdTarea 
							  INNER JOIN TA_Operacion AS TOO ON TOO.IdOperacion =TTO.IdOperacion
							  WHERE TOO.IdOperacion = @IdOperacion)
     AND NOT U.IdUsuario IN (SELECT TOO.IdAsignador
							 FROM TA_Operacion AS TOO
							 WHERE IdOperacion = @IdOperacion)
		
END


