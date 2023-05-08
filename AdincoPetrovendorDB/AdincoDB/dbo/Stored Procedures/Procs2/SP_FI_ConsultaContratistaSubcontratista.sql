-- =============================================
-- Author:		Daniel AC
-- Create date: 24/05/2017
-- Description:	Obtiene la razon social del subcontratista
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaContratistaSubcontratista] 
-- Add the parameters for the stored procedure here
@IdContratista INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         --SELECT S.IdSubcontratista, S.RazonSocial FROM CO_Contratista AS C
         --INNER JOIN  FI_Factura F   On f.id   PV_Subcontratista AS S ON S.IdSubcontratista = C.IdProveedor
         ----WHERE IdContratista = @IdContratista

             /*SELECT S.IdSubcontratista,
                    S.RazonSocial
             FROM PV_Subcontratista AS S
             WHERE S.RazonSocial <> ''
             ORDER BY S.RazonSocial ASC;*/

         SELECT DISTINCT 
                S.IdSubcontratista, 
                UPPER(S.RazonSocial) AS RazonSocial, 
                S.RFC
         FROM PV_Subcontratista AS S
         --FROM CO_Contrato C
         --LEFT OUTER JOIN FI_Factura F ON C.IdContrato = f.IdContrato
         --JOIN PV_Subcontratista AS S ON S.IdSubcontratista = F.IdSubcontratista
         WHERE S.RazonSocial <> ''
               AND S.RazonSocial <> '-'
               AND S.RFC IS NOT NULL
               AND S.RFC <> '-'
               AND S.RFC <> ''
               AND S.IsEliminado = 0
               AND S.IsActivo = 1
         ORDER BY UPPER(S.RazonSocial);
         ----WHERE IdContratista = @IdContratista
     END;