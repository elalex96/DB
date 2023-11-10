
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_ConsultaRelacionadas'
)
    DROP PROCEDURE SP_FI_ConsultaRelacionadas
GO
-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaRelacionadas] 
@IdContrato INT = 0
AS
     BEGIN
         SET NOCOUNT ON;

		SELECT PV_Subcontratista.IdSubcontratista, concat (PV_Subcontratista.RFC, '-', PV_Subcontratista.RazonSocial) AS Empresa
		FROM CO_Contrato
		INNER JOIN CO_RelacionEmpresas
			ON CO_Contrato.IdContratista = CO_RelacionEmpresas.IdContratista
			AND CO_Contrato.IdContrato = @IdContrato
		INNER JOIN PV_Subcontratista
			ON CO_RelacionEmpresas.IdRelacionada = PV_Subcontratista.IdSubcontratista
		WHERE CO_Contrato.IdContrato = @IdContrato

     END;
