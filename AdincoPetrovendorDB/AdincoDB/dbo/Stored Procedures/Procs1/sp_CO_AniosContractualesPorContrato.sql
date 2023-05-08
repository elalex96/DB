-- =============================================
-- Author:		Manuel Cruz
-- Create date:	10-03-17
-- Description:	
-- =============================================
CREATE PROCEDURE dbo.sp_CO_AniosContractualesPorContrato
	-- Add the parameters for the stored procedure here
	@IdContrato int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT AnC.IdAnioContractual AS Id,
       AnC.Anio AS Año,
       AnC.Inicio,
       AnC.Termino,
       Con.NumeroContrato AS Numero_Contrato,
       Contra.NombreContratista AS Contratista,
       ArC.NombreAreaContractual AS Area_Contractual
FROM dbo.CO_AnioContractual AnC
     INNER JOIN CO_Contrato Con ON AnC.IdContrato = Con.IdContrato
     INNER JOIN CO_Contratista Contra ON Con.IdContratista = Contra.IdContratista
     INNER JOIN CO_AreaContractual ArC ON Con.IdAreaContractual = ArC.IdAreaContractual
WHERE Con.IdContrato = @IdContrato;

END
