CREATE FUNCTION dbo.fn_AprobacionFactura
(
	@UUID	VARCHAR(60)
)
RETURNS VARCHAR(250)
BEGIN

	DECLARE @Resultado VARCHAR(250) = ''

	SELECT
		@Resultado	=	CONVERT(VARCHAR(10),APF.FechaModificacion, 105) 
	FROM
		Petrovendor.dbo.FI_Factura	PF (NOLOCK)
	JOIN
		Petrovendor.dbo.MM_AceptacionFactura	AFF	(NOLOCK)
		ON	PF.IdFactura	=	AFF.IdFactura
	JOIN
		Petrovendor.dbo.TA_Operacion APF (NOLOCK)
		ON	AFF.IdAceptacionFactura	=	APF.IdDocumento
		AND APF.IdTipoOperacion = 10 -->Aprobación Factura
	JOIN
		Petrovendor.dbo.TA_Estatus EAF (NOLOCK)
		ON EAF.IdEstatus = APF.IdEstatusOperacion
	WHERE
		LTRIM(RTRIM(PF.UUID))	=	LTRIM(RTRIM(@UUID))

	RETURN @Resultado
END