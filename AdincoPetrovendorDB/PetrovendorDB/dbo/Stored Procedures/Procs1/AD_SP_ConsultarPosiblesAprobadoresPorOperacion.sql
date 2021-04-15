USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AD_SP_ConsultarPosiblesAprobadoresPorOperacion'
)
DROP PROCEDURE AD_SP_ConsultarPosiblesAprobadoresPorOperacion;
GO 
-- =============================================  
-- Author:  Daniel A Cruz  
-- Create date: 05-04-2021  
-- Description:  Consultar los usuarios por empresa u descartando los aprobadores actuales de la operación de entrada
-- =============================================  
CREATE  PROCEDURE [dbo].[AD_SP_ConsultarPosiblesAprobadoresPorOperacion]   
 -- Add the parameters for the stored procedure here  
 @IdOperacion INT,  
 @IdProveedor INT,
 @TipoOperacion NVARCHAR(MAX) 
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
   
   IF @TipoOperacion='COMPRA_DIRECTA'
   BEGIN
    --Obtener aprobadores que no esten participando en el flujo de tarea   
  SELECT U.IdUsuario AS IdUsuario, Nombre +'/'+ TU.NombreTipoUsuario +' ('+(U.Correo)+')'  AS DetalleUsuario  
  FROM S_Usuario AS U  
  INNER JOIN S_TipoUsuario AS TU ON TU.IdTipoUsuario=U.IdTipoUsuario  
  INNER JOIN S_UsuarioProveedor AS UP ON UP.IdUsuario=U.IdUsuario  
  INNER JOIN S_Proveedor  AS P on P.IdProveedor = UP.IdProveedor  
  WHERE  U.Activo=1
  AND P.IdProveedor = @IdProveedor  
  AND  U.IdUsuario NOT  IN (SELECT T.IdAprobador  
							 FROM TA_Tarea AS T            
							 WHERE T.IdOperacion =@IdOperacion )  

	GROUP BY   U.IdUsuario, Nombre,TU.NombreTipoUsuario,U.Correo
   END 

   IF @TipoOperacion='COMPROBANTE_DIRECTO'
   BEGIN 

	  SELECT U.IdUsuario AS IdUsuario, Nombre +'/'+ TU.NombreTipoUsuario +' ('+(U.Correo)+')'  AS DetalleUsuario  
	  FROM S_Usuario AS U  
	  INNER JOIN S_TipoUsuario AS TU ON TU.IdTipoUsuario=U.IdTipoUsuario  
	  INNER JOIN S_UsuarioProveedor AS UP ON UP.IdUsuario=U.IdUsuario  
	  INNER JOIN S_Proveedor  AS P on P.IdProveedor = UP.IdProveedor  
	  WHERE  U.Activo=1
	  AND P.IdProveedor = @IdProveedor  
	  AND  U.IdUsuario NOT  IN (SELECT T.IdAprobador  
								 FROM TA_Tarea AS T            
								 WHERE T.IdOperacion =@IdOperacion
								 AND T.Activo=1 ) 
	 GROUP BY   U.IdUsuario, Nombre,TU.NombreTipoUsuario,U.Correo
   END 
END  
  
