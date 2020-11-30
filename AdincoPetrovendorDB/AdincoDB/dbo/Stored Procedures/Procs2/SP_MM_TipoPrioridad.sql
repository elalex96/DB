-- =============================================
-- Author:		<Daniel AC>
-- Create date: <14-03-2017>
-- Description:	<Mostrar Tipos de Prioridad de SolPed,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_TipoPrioridad] 
-- Add the parameters for the stored procedure here
      
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
 
         -- Insert statements for procedure here

         CREATE TABLE #Prioridad
         (IdPrioridadSolicitudPedido INT,
          Prioridad                  VARCHAR(MAX)
         );
         INSERT INTO #Prioridad
         (IdPrioridadSolicitudPedido,
          Prioridad
         )
         VALUES
         (0,
          '-- Seleccione una prioridad --'
         );
         INSERT INTO #Prioridad
                SELECT IdPrioridadSolicitudPedido,
                       Prioridad
                FROM MM_PrioridadSolicitudPedido AS T;
         SELECT IdPrioridadSolicitudPedido,
                Prioridad
         FROM #Prioridad
         ORDER BY Prioridad ASC;
     END;
