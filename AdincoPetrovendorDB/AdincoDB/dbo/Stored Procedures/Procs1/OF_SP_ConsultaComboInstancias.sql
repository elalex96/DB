-- =============================================
-- Author:		<Jose Roman>
-- Create date: <08/05/2018>
-- Description:	<Se crea consulta para el combo de instancias>
-- =============================================

create PROCEDURE OF_SP_ConsultaComboInstancias
	@IdContrato INT
AS
BEGIN
	SELECT i.idInstanciaEntregable,
		CONCAT( DATENAME(MONTH, i.FechasLimiteaprobacion),'-', DATENAME(year, i.FechasLimiteaprobacion), ' / ', e.DocumentoEntregable) as Instancia
	FROM dbo.EN_InstanciasEntregable i
	INNER JOIN dbo.EN_ContratoEntregable c ON c.IdContratoEntregable = i.IdContratoEntregable
	INNER JOIN dbo.EN_Entregable e ON e.IdEntregable = c.IdEntregable
	WHERE i.Estatus = 10004
		AND c.IdContrato = @IdContrato
END