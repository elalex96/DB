-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 31-03-17
-- Description:	 Consultar Aprobadores recibiendo el IdOperador y IdProveedor
-- =============================================
CREATE  PROCEDURE [dbo].[SP_TA_ConsultarPosiblesAprobadoresPedido] 
	-- Add the parameters for the stored procedure here
	@IdOperacion INT,
	@IdProveedor INT,
	@IdRol INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra resul t sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    --Obtener aprobadores que no esten participando en el flujo de tarea 
     SELECT U.IdUsuario AS IdUsuario, (Nombre +'/'+ TU.NombreTipoUsuario)  AS DetalleUsuario
	 FROM S_Usuario AS U
	 INNER JOIN S_TipoUsuario AS TU ON TU.IdTipoUsuario=U.IdTipoUsuario
	 INNER JOIN S_UsuarioProveedor AS UP ON UP.IdUsuario=U.IdUsuario
	 INNER JOIN S_UsuarioRol AS UR ON UR.IdUsuario = U.IdUsuario
	 INNER JOIN S_ROL AS R ON R.IdRol = UR.IdRol  
	 INNER JOIN S_Proveedor  AS P on P.IdProveedor = UP.IdProveedor
	 WHERE  U.Activo=1 AND P.IdProveedor = @IdProveedor  AND R.IdRol =@IdRol AND UR.Activo = 1
	 AND NOT  U.IdUsuario IN (SELECT T.IdAprobador
							  FROM TA_Tarea AS T 
							  INNER JOIN TA_Operacion AS TOO ON TOO.IdOperacion =T.IdOperacion
							  WHERE TOO.IdOperacion = @IdOperacion)
     AND NOT U.IdUsuario IN (SELECT TOO.IdAsignador
							 FROM TA_Operacion AS TOO
							 WHERE IdOperacion = @IdOperacion)
	 
	 GROUP BY (Nombre + '/' + TU.NombreTipoUsuario),
              U.IdUsuario

		
END

