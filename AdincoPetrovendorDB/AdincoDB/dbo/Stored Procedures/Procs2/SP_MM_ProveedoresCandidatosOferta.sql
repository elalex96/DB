-- =============================================  
-- Author:  Daniel AC  
-- Create date: 08/05/2017  
-- Description: SP Consulta los proveedores candidatos para enviar ofertas  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_MM_ProveedoresCandidatosOferta]  
 -- Add the parameters for the stored procedure here  
    
AS  
     BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
         SET NOCOUNT ON;  
         SELECT P.IdSubcontratista,  
                P.RazonSocial+' '+P.RegimenCapital AS RazonSocial  
         FROM PV_Subcontratista AS P  
              INNER JOIN S_UsuarioProveedor AS UP ON UP.IdProveedor = P.IdSubcontratista  
              INNER JOIN AP_Usuario AS U ON U.UsuarioID = UP.IdUsuario  
         WHERE U.IdTipoUsuario = 4  
               AND U.IsActivo = 1  
               AND P.IsActivo = 1 
			   AND ISNULL(IsGrupo,0)=0
               AND (U.Contraseña IS NOT NULL);  
     END;  