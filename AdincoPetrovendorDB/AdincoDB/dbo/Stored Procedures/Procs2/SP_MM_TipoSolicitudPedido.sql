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

         CREATE TABLE #TipoSolicitud
         (IdTipoSolicitudPedido INT,
          TipoSolicitudPedido   VARCHAR(MAX)
         );
         INSERT INTO #TipoSolicitud
         (IdTipoSolicitudPedido,
          TipoSolicitudPedido
         )
         VALUES
         (0,
          '-- Seleccione Tipo de Solicitud --'
         );
         INSERT INTO #TipoSolicitud
                SELECT IdTipoSolicitudPedido,
                       TipoSolicitudPedido
                FROM MM_TipoSolicitudPedido AS T;
         SELECT IdTipoSolicitudPedido,
                TipoSolicitudPedido
         FROM #TipoSolicitud
         ORDER BY TipoSolicitudPedido ASC;
     END;
