-- =============================================
-- Author:		<Daniel AC>
-- Create date: <14-03-2017>
-- Description:	<Mostrar Tipos de Prioridad de SolPed,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_TipoSolicitudPedido] 
-- Add the parameters for the stored procedure here
      
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
 
         -- Insert statements for procedure here

		 CREATE TABLE #TipoSolicitud(IdTipoSolicitudPedido int, TipoSolicitudPedido varchar(MAX))
		 
		 INSERT INTO  #TipoSolicitud
         SELECT IdTipoSolicitudPedido,  TipoSolicitudPedido
         FROM MM_TipoSolicitudPedido as T 
		 WHERE Activo = 1
         

		 SELECT IdTipoSolicitudPedido, TipoSolicitudPedido FROM #TipoSolicitud  ORDER BY TipoSolicitudPedido ASC;
        
     END;

