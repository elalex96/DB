-- =============================================
-- Author:		Manuel CD
-- ALTER date: 24-08-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ProveedoresPorContrato] 
	-- Add the parameters for the stored procedure here
@IdContrato INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
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
				   AND ISNULL(S.IsEliminado,0) = 0
				   AND S.IsActivo = 1
             ORDER BY UPPER(S.RazonSocial);
         END;

