-- =============================================
-- Author:		<Jose Roman>
-- Create date: <23-05-2018>
-- Description:	<Consulta para el combo de los estados del pozo>
-- =============================================

create PROCEDURE CO_SP_ConsultaComboEstatusPozo
	
AS
BEGIN
	SELECT idEstatus,
			TipoEstatus
	FROM dbo.CO_EstadoPozos
END