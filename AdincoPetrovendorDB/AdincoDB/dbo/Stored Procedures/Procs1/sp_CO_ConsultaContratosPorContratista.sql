-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	Obtiene lista de Contratos por Contratista
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaContratosPorContratista] 
	-- Add the parameters for the stored procedure here
	@IdContratista int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF (@IdContratista =0)
SELECT        CO_Contrato.IdContrato AS Id, CO_Contratista.RazonSocial , CO_Contrato.NumeroContrato, CO_Contrato.DescripcionContrato, CO_AreaContractual.NombreAreaContractual, CO_AreaContractual.Descripcion, 
                         CO_AreaContractual.SuperficieKm2, CO_Region .Nombre AS Region, CO_ActivoCNH.NombreActivo, CO_UbicacionAC .NombreUbicacion  , CO_Contrato.Activo, CO_Contrato.IDRegFiducidiario, CO_Contrato.Duracion, CO_Contrato.FechaFirma, 
                         CO_Contrato.InicioVigencia, CO_Contrato.FinVigencia
FROM            CO_Contrato LEFT JOIN
                         CO_Contratista ON CO_Contrato.IdContratista = CO_Contratista.idcontratista  LEFT JOIN
                         CO_AreaContractual ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual LEFT JOIN
                         CO_Region  ON CO_AreaContractual.IdRegion = CO_Region .IdRegion LEFT JOIN
                         CO_ActivoCNH  ON CO_AreaContractual.IdActivo = CO_ActivoCNH .IdActivo LEFT JOIN
                         CO_UbicacionAC  ON CO_AreaContractual.IdUbicacionAC = CO_UbicacionAC.IdUbicacionAC
where co_contrato.Activo = 1
	ELSE
		BEGIN
SELECT        CO_Contrato.IdContrato AS Id, CO_Contratista.NombreContratista  , CO_Contrato.NumeroContrato, CO_Contrato.DescripcionContrato, CO_AreaContractual.NombreAreaContractual, CO_AreaContractual.Descripcion, 
                         CO_AreaContractual.SuperficieKm2, CO_Region .Nombre AS Region, CO_ActivoCNH.NombreActivo, CO_UbicacionAC .NombreUbicacion  , CO_Contrato.Activo, CO_Contrato.IDRegFiducidiario, CO_Contrato.Duracion, CO_Contrato.FechaFirma, 
                         CO_Contrato.InicioVigencia, CO_Contrato.FinVigencia
FROM            CO_Contrato LEFT JOIN
                         CO_Contratista ON CO_Contrato.IdContratista = CO_Contratista.IdContratista   LEFT JOIN
                         CO_AreaContractual ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual LEFT JOIN
                         CO_Region  ON CO_AreaContractual.IdRegion = CO_Region .IdRegion LEFT JOIN
                         CO_ActivoCNH  ON CO_AreaContractual.IdActivo = CO_ActivoCNH .IdActivo LEFT JOIN
                         CO_UbicacionAC  ON CO_AreaContractual.IdUbicacionAC = CO_UbicacionAC.IdUbicacionAC
where co_contrato.Activo = 1  and CO_Contratista.IdContratista  = @IdContratista 
		END
END


