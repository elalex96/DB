-- =============================================
-- Author:		Manuel Cruz
-- Create date: 20-05-2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENI_PlanTmp] 
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         --SELECT Fecha, 
         --       Evento
         --FROM dbo.ENI_PlanTmp;

		 SELECT
			E.DocumentoEntregable, ISNULL(IE.FechaRealEntregaRegulador,IE.FechaCalculadaEntregaReg) AS Fecha, E.DocumentoEntregable AS Evento
		FROM
			EN_Entregable E
		JOIN EN_ContratoEntregable CE ON E.IdEntregable = CE.IdEntregable
			AND E.BitInterno = 1
			AND CE.IdContrato = @IdContrato
			AND E.DocumentoEntregable LIKE 'Aprobación%Plan%'
			AND CE.Activo = 1
		JOIN EN_InstanciasEntregable IE ON CE.IdContratoEntregable = IE.IdContratoEntregable

     END;