-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2017
-- Description:	
-- =============================================
CREATE PROCEDURE sp_CO_ConsultaInformacionContrato 
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
                         CO_Contratista.DocumentoLegal, CO_Contratista.IDSIPAC, CO_Contrato.NumeroContrato, CO_Contrato.DescripcionContrato, CO_Contrato.IDRegFiducidiario, CO_Contrato.Duracion, CO_Contrato.FechaFirma, 
                         CO_Contrato.InicioVigencia, CO_Contrato.FinVigencia, CO_Contrato.ValorRegaliaAdicional, CO_Contrato.IncrementoProgramaMinimo, CO_AreaContractual.IdAreaContractualPemex, 
                         CO_AreaContractual.NombreAreaContractual, CO_AreaContractual.Descripcion, CO_AreaContractual.SuperficieKm2, CO_TipoContrato.TipoContratoCorto, CO_TipoContrato.TipoContrato, 
                         CO_Region.Nombre AS Region, PV_EstadoRepublica.Estado
FROM            CO_Contrato INNER JOIN
                         CO_AreaContractual ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual INNER JOIN
                         CO_Contratista ON CO_Contrato.IdContratista = CO_Contratista.IdContratista INNER JOIN
                         CO_TipoContrato ON CO_Contrato.IdTipoContrato = CO_TipoContrato.IdTipoContrato INNER JOIN
                         CO_Region ON CO_AreaContractual.IdRegion = CO_Region.IdRegion INNER JOIN
                         PV_EstadoRepublica ON CO_AreaContractual.IdEstado = PV_EstadoRepublica.idEstado
WHERE        (CO_Contrato.IdContrato = @IdContrato)
END
