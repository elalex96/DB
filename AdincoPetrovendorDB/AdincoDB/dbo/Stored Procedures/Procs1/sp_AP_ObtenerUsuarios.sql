-- =============================================  
-- Author:  Oscar Mtz  
-- Create date: 29/06/2017  
-- Description: Devuelve el listado de los usuarios registrados.  
-- =============================================  
CREATE PROCEDURE dbo.sp_AP_ObtenerUsuarios  
AS  
BEGIN   
 SELECT [UsuarioID]  
    ,[Usuario]  
    ,[Contraseña]  
    ,[Nombre]  
    ,[IsActivo]  
    ,[fchRegistro]  
    ,[IsEliminado]  
    ,[imgsrc]  
    ,[image]  
    ,ISNULL([UltimoAcceso],'') UltimoAcceso  
    ,ISNULL([Idioma],0) Idioma  
    ,ISNULL([CreadoPor],0) CreadoPor  
    ,ISNULL([Sello],'') Sello  
   FROM [dbo].[AP_Usuario]  
   WHERE  ISNULL(IsGrupo,0)=0;
  END