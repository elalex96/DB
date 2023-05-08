CREATE FUNCTION dbo.fnGetPedidoFacturas
(
	@pIdPedido INT,
	@pIdEstatusOperacion	INT
)
RETURNS varchar(350)
AS
BEGIN
	DECLARE @Facturas VARCHAR (2000) = ''

	SELECT @Facturas = @Facturas + LTRIM(RTRIM(CONCAT(ISNULL(FA.Serie,''),' ',ISNULL(fa.Folio,'')))) + ', '
	FROM MM_Pedidos	PS (NOLOCK)
	JOIN dbo.MM_Pedido	P	(NOLOCK)
		ON	PS.IdIdentificador	=	P.IdPedido
		AND PS.IdPedido = @pIdPedido
	JOIN MM_AceptacionPedido	AP	(NOLOCK)
		ON	P.IdPedido	=	AP.IdPedido
	JOIN MM_AceptacionFactura AS AF	(NOLOCK)
		 ON AP.IdAceptacionPedido	=	AF.IdAceptacionPedido
	JOIN TA_Operacion APF	(NOLOCK)
		ON AF.IdAceptacionFactura	=	APF.IdDocumento
		AND APF.IdEstatusOperacion	=	@pIdEstatusOperacion
	JOIN dbo.FI_Factura AS FP	(NOLOCK)
		 ON AF.IdFactura = FP.IdFactura
          AND FP.Activa = 1
     JOIN Adinco.dbo.FI_Factura AS FA (NOLOCK)
		ON FP.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = FA.UUID
	WHERE PS.IdPedido = @pIdPedido
		AND APF.IdEstatusOperacion	=	@pIdEstatusOperacion
		--AND FA.IdFactura	IS NOT NULL

	IF LEN(@Facturas) > 0 
		SELECT @Facturas = ISNULL(SUBSTRING(@Facturas,1,LEN(@Facturas)-1),'')

	RETURN @Facturas
END

