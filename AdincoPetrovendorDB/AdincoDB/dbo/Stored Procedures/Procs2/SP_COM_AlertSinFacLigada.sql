-- =============================================
-- Author:		Manuel Cruz
-- Create date: 23-07-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_COM_AlertSinFacLigada] --3,'20180101',1
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@MesReporte DATE, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         /*SELECT COUNT(IdOperacionComercializacion)
         FROM dbo.COM_OperacionComercializacion
         WHERE(MesReporte = @MesReporte
               AND IdContrato = @IdContrato)
              AND IdFactura = 0;*/

         SELECT COUNT(IdOperacionComercializacion) AS [TotalComer], 
                ISNULL(SUM(CASE
                               WHEN ISNULL(IdFactura, 0) = 0
                               THEN 1
                               ELSE 0
                           END), 0) AS [SinLigar]
         FROM dbo.COM_OperacionComercializacion
         WHERE MesReporte = @MesReporte
               AND IdContrato = @IdContrato;
     END;