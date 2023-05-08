-- =============================================  
-- Author:  DANIEL AC  
-- Create date: 25-01-18  
-- Description: Consultar usuarios por contrato   
-- =============================================  
CREATE PROCEDURE [dbo].[SP_MA_ConsultarUsuariosxContrato]  
-- Add the parameters for the stored procedure here  
@IdUsuario INT,  
@IdContrato INT=0,  
@IdSubcontratista INT =0,  
@FechaRegistro DATETIME= '25-01-2017 00:00'  
  
AS  
BEGIN  
    SET NOCOUNT ON;  
              
    SELECT U.UsuarioID,U.Nombre  FROM   
    dbo.AP_Usuario U  
    INNER JOIN  AP_PerfilUsuario AS PU ON PU.UsuarioID=U.UsuarioID  
    INNER JOIN AP_Perfil AS P ON P.IdPerfil= PU.PerfilID  
    INNER JOIN dbo.CO_Contrato AS C ON C.IdContrato= P.IdContrato   
    WHERE C.IdContrato=@IdContrato AND U.IsActivo=1  AND ISNULL(IsGrupo,0)=0
    GROUP BY U.UsuarioID,U.Nombre  
    ORDER BY U.Nombre ASC  
         
END;  
  