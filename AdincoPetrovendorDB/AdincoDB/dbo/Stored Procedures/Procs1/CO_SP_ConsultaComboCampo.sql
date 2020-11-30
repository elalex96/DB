-- =============================================
-- Author:		<Jose Roman>
-- Create date: <23-05-2018>
-- Description:	<Consulta para el combo de campos>
-- =============================================

CREATE PROCEDURE CO_SP_ConsultaComboCampo
	
AS
BEGIN
	SELECT IdCampo,
			NombreCampo	AS [DescripcionCampo]
	FROM dbo.PD_Campo
	WHERE	Activo	=	1
END