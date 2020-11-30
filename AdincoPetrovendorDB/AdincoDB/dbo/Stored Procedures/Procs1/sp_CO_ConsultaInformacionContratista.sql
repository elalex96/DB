-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaInformacionContratista] 
	-- Add the parameters for the stored procedure here
	@IdContrato int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT        CO_Contratista.NombreContratista, CO_Contratista.Representante, CO_Contratista.PuestoRepresentante, CO_Contratista.RazonSocial, CO_Contratista.Calle, CO_Contratista.Numero, CO_Contratista.Colonia, 
                         CO_Contratista.Municipio, CO_Contratista.Entidad, CO_Contratista.CodigoPostal, CO_Contratista.Pais, CO_Contratista.RFC, CO_Contratista.CorreoElectronico, CO_Contratista.Telefono, CO_Contratista.PaginaWeb, 
                         CO_Contratista.DocumentoLegal, CO_Contratista.IDSIPAC
FROM            CO_Contrato LEFT JOIN
                         CO_AreaContractual ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual LEFT JOIN
                         CO_Contratista ON CO_Contrato.IdContratista = CO_Contratista.IdContratista LEFT JOIN
                         CO_TipoContrato ON CO_Contrato.IdTipoContrato = CO_TipoContrato.IdTipoContrato LEFT JOIN
                         CO_Region ON CO_AreaContractual.IdRegion = CO_Region.IdRegion LEFT JOIN
                         PV_EstadoRepublica ON CO_AreaContractual.IdEstado = PV_EstadoRepublica.idEstado
WHERE        (CO_Contrato.IdContrato = @IdContrato)
END
