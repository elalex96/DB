-- =============================================
-- Author:		<Jose Roman>
-- Create date: <23-05-2018>
-- Description:	<Consulta de las instalaciones por contrato>
-- =============================================

CREATE procedure [dbo].[CO_SP_ConsultaInstalacionesPorContrato]
	@IdContrato INT
AS
BEGIN
	SELECT i.IdInstalacion,
			i.NombreInstalacion,
			i.IdInstalacionPemex,
			i.EsBolsa,
			i.IdActividad,
			i.NombreInstalacionAlterno,
			i.IdCatalogoSCIEP,
			i.IdYacimiento,
			i.IdCampo,
			i.UTMX,
			i.UTMY,
			i.IdEstatus
	FROM dbo.CO_Instalacion i
	INNER JOIN dbo.CO_Contrato c ON c.IdAreaContractual = i.IdAreaContractual
	WHERE c.IdContrato = @IdContrato AND i.Activo = 1
END