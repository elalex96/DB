-- =============================================
-- Author:		Oscar Mtz
-- Create date: 03/07/2017
-- Description:	Devuelve el listado de los perfiles existentes.
-- =============================================
CREATE PROCEDURE dbo.sp_AP_ObtenerPerfil 	
AS
BEGIN
SELECT [IdPerfil]
      ,[IdRol]
      ,[IdContrato]
      ,[Descripcion]
      ,ISNULL([CreadoPor],0) CreadoPor
  FROM [dbo].[AP_Perfil]
END