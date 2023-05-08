-- =============================================
-- Author:		<Jose Roman>
-- Create date: <23-05-2018>
-- Description:	<Consulta para el combo de actividad>
-- =============================================

create PROCEDURE CO_SP_ConsultaComboActividad
	
AS
BEGIN
	SELECT IdActividad,
			NombreActividad
	FROM dbo.CO_ActividadCIEP
END