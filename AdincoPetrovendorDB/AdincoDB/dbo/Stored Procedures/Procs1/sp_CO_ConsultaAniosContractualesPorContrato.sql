-- =============================================
-- Author:		Miguel
-- Create date: 29-Sep-2014
-- Description:	Obtiene los años contractuales por contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaAniosContractualesPorContrato] 
	-- Add the parameters for the stored procedure here
	@IdContrato int =0
as
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements fdbo.CO_AnioContractual.or procedure here
	SELECT        IdAnioContractual AS Id, dbo.CO_AnioContractual.Anio AS Año, dbo.CO_AnioContractual.Inicio, dbo.CO_AnioContractual.Termino, dbo.CO_Contrato.NumeroContrato AS Numero_Contrato, 
                         dbo.CO_Contratista.NombreContratista AS Contratista, dbo.CO_AreaContractual.NombreAreaContractual AS Area_Contractual
FROM            dbo.CO_AnioContractual INNER JOIN
                         dbo.CO_Contrato ON dbo.CO_AnioContractual.IdContrato = dbo.CO_Contrato.IdContrato INNER JOIN
                         dbo.CO_Contratista ON dbo.CO_Contrato.IdContratista = dbo.CO_Contratista.IdContratista INNER JOIN
                         dbo.CO_AreaContractual ON dbo.CO_Contrato.IdAreaContractual = dbo.CO_AreaContractual.IdAreaContractual
	WHERE CO_Contrato.IdContrato = @IdContrato
END


