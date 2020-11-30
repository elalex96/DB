-- =============================================
-- Author:		Miguel Gomez
-- Create date: Dieciembre 2014
-- Description:	Obtiene la informacion de un contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaContrato] 
	-- Add the parameters for the stored procedure here
	@IdContrato int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT        CO_Contrato.IdContrato, CO_Contrato.NumeroContrato, CO_Contrato.DescripcionContrato, CO_Contrato.IdContratista, CO_Contrato.IdAreaContractual, CO_Contrato.Activo, CO_Contratista.NombreContratista, 
                         CO_AreaContractual.NombreAreaContractual, CO_Contrato.IDRegFiducidiario, CO_Contrato.Duracion, CO_Contrato.FechaFirma, CO_Contrato.InicioVigencia, CO_Contrato.FinVigencia, 
                         CO_TipoContrato.TipoContratoCorto, CO_TipoContrato.TipoContrato,
						 RFCContratista = CO_Contratista.rfc
FROM            CO_Contrato 
				INNER JOIN   CO_Contratista ON CO_Contrato.IdContratista = CO_Contratista.IdContratista 
				LEFT JOIN    CO_AreaContractual ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual 
				left JOIN    CO_TipoContrato ON CO_Contrato.IdTipoContrato = CO_TipoContrato.IdTipoContrato
WHERE        (CO_Contrato.IdContrato = @IdContrato)
END

