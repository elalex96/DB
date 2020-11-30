CREATE PROC [dbo].[SP_DeudaSemanalPago]
@anio INT,
@mes INT,
@semana INT,
@idcontrato INT 
AS
BEGIN 
DECLARE
@diaIni int
,@diaFin int;

IF @semana = 0
BEGIN
 SET @diaIni = 1
 SET @diaFin = 31
END
IF @semana = 1
BEGIN
 SET @diaIni = 1
 SET @diaFin = 7
END


IF @semana = 2
BEGIN
 SET @diaIni = 8
 SET @diaFin = 14
END

IF @semana = 3
BEGIN
 SET @diaIni = 15
 SET @diaFin = 21
END

IF @semana = 4
BEGIN
 SET @diaIni = 22
 SET @diaFin = 31
END

  SELECT
        APF.FechaModificacion, PF.UUID,AP.IdPedido, Petrovendor.dbo.fnGetInstalacion(P.IdSolicitudPedido) AS [Instalación], P.DiasCredito,SP.MotivoUrgencia
    INTO #DatosPetrovendor
    FROM
        Petrovendor.dbo.FI_Factura    PF (NOLOCK)
    JOIN
        Petrovendor.dbo.MM_AceptacionFactura    AFF    (NOLOCK)
        ON    PF.IdFactura    =    AFF.IdFactura
    JOIN
        Petrovendor.dbo.TA_Operacion APF (NOLOCK)
        ON    AFF.IdAceptacionFactura    =    APF.IdDocumento
        AND APF.IdTipoOperacion = 10 -->Aprobación Factura
    JOIN
        Petrovendor.dbo.TA_Estatus EAF (NOLOCK)
        ON EAF.IdEstatus = APF.IdEstatusOperacion
    JOIN
        Petrovendor.dbo.MM_AceptacionPedido AS AP (NOLOCK)
        ON AFF.IdAceptacionPedido = AP.IdAceptacionPedido
    JOIN
        Petrovendor.dbo.MM_Pedido    P
        ON    AP.IdPedido    =    P.IdPedido
	JOIN Petrovendor.dbo.MM_SolicitudPedido AS SP
		ON SP.IdSolicitudPedido = P.IdSolicitudPedido

		WHERE p.IdContrato = @idcontrato
		AND YEAR(APF.FechaModificacion)= @anio
		AND MONTH(APF.FechaModificacion)= @mes
		aND DAY(APF.FechaModificacion) BETWEEN @diaIni AND @diaFin
    
	SELECT
	DISTINCT
		Petro.UUID
		,ISNULL(s.RazonSocial, '')+' '+ISNULL(s.RegimenCapital, '') AS Proveedor
		,CONCAT(F.Serie, '', F.Folio) AS Factura
		,CONVERT(VARCHAR(10),F.Fecha, 120) AS 'Fecha'
		,CONVERT(VARCHAR(10),Petro.FechaModificacion, 120) AS 'Fecha Recepcion'
		--Montos
	,CASE WHEN F.IdMoneda = 1
			THEN
			F.SubTotal ELSE NULL END AS 'Subtotal MXN',

			CASE WHEN F.IdMoneda = 1
			THEN
			ISNULL((F.SubTotal * .16), 0) ELSE NULL END AS 'IVA MXM', 
			'' AS 'OTROS IMP MXN',

			CASE WHEN F.IdMoneda = 1
			THEN
			F.MontoConIva ELSE NULL END AS 'Total MXN',

			CASE WHEN F.IdMoneda = 2
			THEN
			F.SubTotal ELSE NULL END AS 'Subtotal USD',

			CASE WHEN F.IdMoneda = 2
			THEN
			ISNULL((F.SubTotal * .16), 0) ELSE NULL END AS 'IVA USD',
			'' AS 'OTROS IMP USD',
			CASE WHEN F.IdMoneda = 2
			THEN
			F.MontoConIva ELSE NULL END AS 'Total USD'
			,Petrovendor.dbo.fnGetInstalacion(P.IdSolicitudPedido)	AS [Instalación]
			,Petro.MotivoUrgencia AS [Descripcion del servicio]
			,CASE WHEN P.DiasCredito IS NULL 	THEN	ISNULL(P.DiasCredito,60)
			WHEN	P.DiasCredito = 0 THEN 60
			ELSE	P.DiasCredito
			END	 AS [Linea de Credito]

	--/Montos
    FROM
        #DatosPetrovendor  Petro
    JOIN
        dbo.FI_Factura    F
        ON    Petro.UUID COLLATE Modern_Spanish_CI_AS    =    F.UUID
    JOIN
        dbo.PV_Subcontratista    S
        ON    F.IdSubcontratista    =    S.IdSubcontratista
	JOIN Petrovendor.dbo.FI_Factura AS PF ON F.IdContrato = PF.IdContrato
	JOIN Petrovendor.dbo.MM_Pedido AS P ON P.IdPedido = Petro.IdPedido
	LEFT JOIN dbo.MM_SolicitudPedido	SOLPED	(NOLOCK)
	ON	P.IdSolicitudPedido	=	SOLPED.IdSolicitudPedido

END


