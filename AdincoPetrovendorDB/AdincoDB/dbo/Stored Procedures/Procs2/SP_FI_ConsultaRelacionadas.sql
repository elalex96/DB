-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE SP_FI_ConsultaRelacionadas 
	-- Add the parameters for the stored procedure here
@IdContrato INT = 0
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
SELECT        S.IdSubcontratista, concat (S.RFC, '-',S.RazonSocial) AS Empresa
FROM            CO_Contrato AS C INNER JOIN
                         CO_RelacionEmpresas AS RE ON RE.IdContratista = C.IdContratista INNER JOIN
                         PV_Subcontratista AS S ON S.IdSubcontratista = RE.IdRelacionada
					WHERE c.IdContrato= @IdContrato
    -- Insert statements for procedure here

     END;
