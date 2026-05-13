-- =============================================  
-- Author:  Daniel A Cruz  
-- Create date: 05-01-18  
-- Description:  Consultar posibles aprobadores   
-- =============================================  
CREATE  PROCEDURE [dbo].[SP_MA_ConsultarPosiblesAprobadores]    
 -- Add the parameters for the stored procedure here  
 @IdUsuario INT,  
 @IdOperacion INT,   
 @IdContrato INT,    
 @IdSubcontratista INT =0,  
 @FechaRegistro DATETIME= '25-01-2017 00:00'   
  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
     
    SELECT U.UsuarioID,U.Nombre  FROM   
    dbo.AP_Usuario U  
    INNER JOIN  AP_PerfilUsuario AS PU ON PU.UsuarioID=U.UsuarioID  
    INNER JOIN AP_Perfil AS P ON P.IdPerfil= PU.PerfilID  
    INNER JOIN dbo.CO_Contrato AS C ON C.IdContrato= P.IdContrato   
    WHERE C.IdContrato=@IdContrato AND U.IsActivo=1  
    AND NOT U.UsuarioID  IN (  
    SELECT IdAprobador FROM dbo.MA_OperacionDetalle OD  
    INNER JOIN dbo.MA_Operacion O ON O.IdOperacion=OD.IdOperacionDetalle  
    WHERE O.IdOperacion=@IdOperacion        
    )  
    AND NOT U.UsuarioID IN (SELECT O.IdUsuarioRegistro FROM dbo.MA_Operacion O WHERE O.IdOperacion=@IdOperacion)  
	AND ISNULL(U.IsGrupo,0)=0
    GROUP BY U.UsuarioID,U.Nombre  
    ORDER BY U.Nombre ASC  
         
        
 END  
  
  
  
  
  
  