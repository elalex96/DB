-- =============================================  
-- Author:  <Daniel AC>  
-- Create date: <05-04-2021>  
-- Description: <Consulta usuarios que sean del rol de compra directa>  
-- =============================================  
CREATE PROCEDURE [dbo].[AD_SP_UsuariosRolAprobacionxTipoAprobacion]   
@IdProveedor INT,  
@TipoAprobacion NVARCHAR(MAX)    
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
  IF @TipoAprobacion='COMPRA_DIRECTA'
  BEGIN 
		 SELECT DISTINCT   
		  U.IdUsuario,  
		  U.Nombre,  
		  TU.NombreTipoUsuario AS Nombre  
		 FROM dbo.S_Usuario U  
		 INNER JOIN S_TipoUsuario AS TU   
		  ON TU.IdTipoUsuario=U.IdTipoUsuario  
		 INNER JOIN dbo.S_UsuarioRol UR   
		  ON UR.IdUsuario = U.IdUsuario  
		 INNER JOIN dbo.S_Rol R   
		  ON R.IdRol = UR.IdRol  
		 INNER JOIN dbo.S_UsuarioProveedor UP  
		  ON UP.IdUsuario = U.IdUsuario  
		 INNER JOIN dbo.S_Proveedor P   
		  ON P.IdProveedor = UP.IdProveedor  
		 INNER JOIN dbo.TA_TipoOperacion TIOP  
		  ON TIOP.IdRol = R.IdRol  
		 WHERE   
		  U.Activo=1  ---> USUARIO SE ENCUENTRE ACTIVO  
		  AND P.IdProveedor =@IdProveedor   
		  AND UR.Activo= 1 ---> ROL SE ENCUENTRE ACTIVO  
		  AND TIOP.IdTipoOperacion = 14 --> APROBACIÓN DE  COMPRA DIRECTA    
		 GROUP BY U.Nombre, TU.NombreTipoUsuario,  
					 U.IdUsuario  
		 ORDER BY U.Nombre ASC  
  
  END 
  
END  
