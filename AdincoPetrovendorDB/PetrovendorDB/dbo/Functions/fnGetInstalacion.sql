CREATE FUNCTION dbo.fnGetInstalacion
(
	@pIdSolicitudPedido	INT
)
RETURNS VARCHAR(250)
AS
BEGIN
	DECLARE @Instalacion VARCHAR(250) = ''

	SELECT
		@Instalacion	=	@Instalacion + I.NombreInstalacion + ', '
	FROM
		MM_SolicitudPedidoDetalle	SPD	(NOLOCK)
	JOIN
		MM_SolicitudPedidoDetalleLineaPresupuesto	SPDL	(NOLOCK)
		ON	SPD.IdSolicitudPedidoDetalle	=	SPDL.IdSolicitudPedidoDetalle
		AND SPD.IdSolicitudPedido	=	@pIdSolicitudPedido
	JOIN
		Adinco.dbo.CO_Instalacion	I	(NOLOCK)
		ON	SPDL.IdInstalacion	=	I.IdInstalacion
	GROUP BY
		I.NombreInstalacion

	IF LEN(@Instalacion) > 0   
		SELECT @Instalacion = ISNULL(SUBSTRING(@Instalacion,1,LEN(@Instalacion)-1),'')  

	RETURN @Instalacion
END