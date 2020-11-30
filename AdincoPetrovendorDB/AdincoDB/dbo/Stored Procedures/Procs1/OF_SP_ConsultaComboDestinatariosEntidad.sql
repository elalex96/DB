-- =============================================
-- Author:		<Jose Roman>
-- Create date: <08/05/2018>
-- Description:	<Se crea consulta para combo destinatarios por entidad>
-- =============================================

create PROCEDURE OF_SP_ConsultaComboDestinatariosEntidad
	@IdEntidad INT,
	@IdContrato INT
AS
BEGIN
	SELECT d.idDestinatarioEntidad, CONCAT(ISNULL(s.AbreviaturaTitulo, ''), ' ', d.Nombre, ' ', d.ApellidoPaterno, ' ', d.ApellidoMaterno) AS Nombre
	FROM dbo.EN_DestinatarioEntidad d
	INNER JOIN dbo.EN_DestinatarioOficioEntidadContrato de ON de.idDestinatarioEntidad = d.idDestinatarioEntidad
	LEFT JOIN dbo.Des_SaludoTitulo s ON s.idTitulo = d.idTitulo
	WHERE de.idContrato = @IdContrato
		AND de.idEntidad = @IdEntidad
END