

CREATE PROCEDURE [dbo].[SP_APR_ConsultaAceptacionPedidoCabecera] --2243,420
(	-- Add the parameters for the stored procedure here
	
	--declare 
	@IdAceptacionPedido INT,
	@IdProveedor INT
)
	--select @IdAceptacionPedido = 12197, @IdProveedor = 907
	--select @IdAceptacionPedido = 7185, @IdProveedor = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IdPedido INT; 
	DECLARE @CondionesPago NVARCHAR(MAX);

	--OBTENER EL PEDIDO DE LA ACEPTACION PARA LAS CONDICIONES DE PAGO
	SET @IdPedido= (SELECT 
						AP.IdPedido
					FROM dbo.MM_AceptacionPedido AP
						LEFT JOIN dbo.MM_Pedido P ON P.IdPedido=AP.IdPedido
					WHERE  P.IdProveedorCompras = @IdProveedor
						AND AP.IdAceptacionPedido = @IdAceptacionPedido);

	--OBTENER LAS CONDICIONES DE PAGO
	SELECT @CondionesPago = CASE 
								WHEN pd.IdCondicionPago = 1 THEN CONCAT(pd.DiasCredito, CASE 
																							WHEN PD.DiasCredito = 1 THEN ' días' 
																							ELSE ' días' 
																						END,' de ', cp.CondicionPago)
								ELSE CONCAT(cp.CondicionPago,'')
							END 
	FROM dbo.MM_PedidoDetalle pd
		LEFT JOIN dbo.MM_CondicionPago cp 
			ON cp.IdCondicionPago = pd.IdCondicionPago
	WHERE IdPedido = @IdPedido
	GROUP BY CASE
             WHEN pd.IdCondicionPago = 1 THEN
             CONCAT(   pd.DiasCredito,
             CASE
             WHEN pd.DiasCredito = 1 THEN
             ' días'
             ELSE
             ' días'
             END,
             ' de ',
             cp.CondicionPago
             )
             ELSE
             CONCAT(cp.CondicionPago, '')
             END;



		--Verificar si la aceptación tiene carta CN
	DECLARE @TieneCarta BIT  = 0

	SET @TieneCarta = (
							SELECT 
										TieneCarta	=	CASE WHEN APC.IdAceptacionPedido IS NOT NULL THEN 1 ELSE 0 END
							FROM		dbo.MM_AceptacionPedido AP
							LEFT JOIN	dbo.MM_AceptacionCartaPCN APC
							ON			AP.IdAceptacionPedido = APC.IdAceptacionPedido
							WHERE		AP.IdAceptacionPedido = @IdAceptacionPedido
							and			APC.IdEstatus			= 2
					 )



	--CABECERA
	SELECT
		CASE
			WHEN @TieneCarta = 0 THEN CAST(AP.IdAceptacionPedido AS NVARCHAR(300))
			ELSE
			CAST(AP.IdAceptacionPedido AS NVARCHAR(300)) 
			--' (No se puede reclasificar esta aceptación, debido a que ya se realizó una carta de contenido nacional)'
		END IdAceptacionPedido,
		PS.IdPedido AS IdPedidoGeneral,
		PR.RazonSocial AS Proveedor,
		AP.Creado AS FechaAceptacion,
		UREQ.Nombre AS Requisitor,
		SP.IdSolicitudPedido,
		UCOM.Nombre AS Comprador,
		AP.NombreRecibidoPor,
		AP.NombreUsuarioEntrega,
		CASE 
			WHEN P.UnicaCondicionPago = 1 THEN CONCAT(@CondionesPago,'')
			ELSE 'Diferidas para las partidas de la orden de compra'
		END AS CondicionesPago,
		CONCAT(CASE
					WHEN DG.Calle IS NULL THEN ''
					ELSE 'Calle ' + DG.Calle
				END,
				CASE
					WHEN DG.NoExterior IS NULL THEN ''
					ELSE ' No Ext ' + DG.NoExterior
				END,
				CASE
					WHEN DG.NoInterior IS NULL THEN ''
					ELSE ' No Int ' + DG.NoInterior
				END,
				CASE
					WHEN DG.Colonia IS NULL THEN ''
					ELSE ' Colonia ' + DG.Colonia + ' '
				END,
				CASE
					WHEN DG.Municipio IS NULL THEN ''
					ELSE DG.Municipio + ' ,'
				END,
				CASE
					WHEN DG.Estado IS NULL THEN ''
					ELSE DG.Estado + ' ,'
				END,
				CASE
					WHEN DG.Pais IS NULL THEN ''
					ELSE DG.Pais + ' ,'
				END,
				CASE
					WHEN DG.CodigoPostal IS NULL THEN ''
					ELSE ' CP ' + DG.CodigoPostal
				END ) AS Direccion,
				STUFF((SELECT 
							', '  + CC.CentroCosto
						FROM dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI
							LEFT JOIN dbo.MM_AceptacionPedidoDetalle AS APD
								ON APD.IdAceptacionPedidoDetalle = APDI.IdAceptacionPedidoDetalle
							LEFT JOIN dbo.MM_PedidoDetalle AS PD
								ON PD.IdPedidoDetalle = APDI.IdPedidoDetalle
							LEFT JOIN dbo.MM_PeticionOfertaDetalle AS POD
								ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
							LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
								ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
							LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP
								ON SPDLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
							LEFT JOIN dbo.CC_CentroCosto AS CC
								ON CC.IdCentroCosto = SPDLP.IdCentroCosto
						WHERE APD.IdAceptacionPedido = AP.IdAceptacionPedido
						GROUP BY CC.CentroCosto
						FOR XML PATH('')), 1, 2, ''
						) As CentroCostos
		FROM dbo.MM_AceptacionPedido AS AP
			LEFT JOIN dbo.MM_Pedido AS P 
				ON P.IdPedido = AP.IdPedido
			LEFT JOIN dbo.S_Proveedor AS PR 
				ON PR.IdProveedor = P.IdSubcontratista
			LEFT JOIN dbo.MM_SolicitudPedido AS SP 
				ON SP.IdSolicitudPedido = P.IdSolicitudPedido
			LEFT JOIN dbo.MM_Pedidos AS PS 
				ON PS.IdIdentificador = P.IdPedido AND PS.IdProveedorCliente = P.IdProveedorCompras
			LEFT JOIN dbo.S_Usuario AS UREQ 
				ON UREQ.IdUsuario = SP.IdUsuarioSolicitante
			LEFT JOIN dbo.S_Usuario AS UCOM 
				ON UCOM.IdUsuario = P.CreadoPor
			LEFT JOIN DG_Domicilio AS DG
				ON DG.IdDomicilio = AP.IdDomicilioEntrega
			LEFT JOIN PV_PaisRepublica AS PSG
				ON PSG.id = DG.IdPais
		WHERE AP.IdAceptacionPedido = @IdAceptacionPedido;


	--DETALLES

	--IF(@TieneCarta = 0) --- no tiene carta -> mostrar
	--BEGIN
	    	SELECT
			ROW_NUMBER() OVER(ORDER BY APD.IdAceptacionPedidoDetalle ASC) AS _key,
			APD.IdAceptacionPedidoDetalle,
			MM.IdMaterial,
			CONCAT(MM.DescripcionCorta, 
				' - Marca: ', CASE
								WHEN MM.Marca = '' OR MM.Marca IS NULL THEN 'S/M'
								ELSE MM.Marca
							END, 
				' Modelo: ', CASE
								WHEN MM.Modelo = '' OR MM.Modelo IS NULL THEN 'S/M'
								ELSE MM.Modelo
							END, 
				' No. Parte:',CASE
								WHEN MM.NumeroParte = '' OR MM.NumeroParte IS NULL THEN 'S/NP'
								ELSE MM.NumeroParte
							END) AS NombrePartida,
			APD.Cantidad,
			(PD.PrecioUnitario * APD.Cantidad) AS Monto,
			MO.TipoMonedaCorto,
			INS.NombreInstalacion AS Instalacion,
			dbo.Fn_RetornarMesProgramadoActividadConcat(LP.IdLineaPresupuestoMes) AS LineaPresupuesto
			FROM dbo.MM_AceptacionPedido AS AP
				LEFT JOIN dbo.MM_AceptacionPedidoDetalle AS APD 
					ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN dbo.MM_PedidoDetalle AS PD
					ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
				LEFT JOIN dbo.MM_Material AS MM
					ON MM.IdMaterial = PD.IdMaterial
				LEFT JOIN dbo.PV_TipoMoneda AS MO
					ON MO.IdMoneda = PD.IdMoneda
				LEFT JOIN dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI
					ON APDI.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
				LEFT JOIN Adinco.dbo.CO_Instalacion AS INS
						ON INS.IdInstalacion = APDI.IdInstalacion
				LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS LP 
						ON LP.IdLineaPresupuestoMes = APDI.IdLineaPresupuesto
			WHERE AP.IdAceptacionPedido = @IdAceptacionPedido;


	--END
	--ELSE
    --BEGIN
        	SELECT
			ROW_NUMBER() OVER(ORDER BY APD.IdAceptacionPedidoDetalle ASC) AS _key,
			APD.IdAceptacionPedidoDetalle,
			MM.IdMaterial,
			'<div class="mcs-alert alert-warning ">
                        <i class="fas fa-exclamation-circle alert-icon"></i>
                        <span class="alert-message">Está aceptación de servicio no se puede reclasificar, debido a que el proveedor realizó el cálculo de la carta de contenido nacional</span>
                        
            </div>'
			 AS NombrePartida,
			0 AS Cantidad,
			0 AS Monto,
			MO.TipoMonedaCorto,
			INS.NombreInstalacion AS Instalacion,
			dbo.Fn_RetornarMesProgramadoActividadConcat(LP.IdLineaPresupuestoMes) AS LineaPresupuesto
			FROM dbo.MM_AceptacionPedido AS AP
				LEFT JOIN dbo.MM_AceptacionPedidoDetalle AS APD 
					ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN dbo.MM_PedidoDetalle AS PD
					ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
				LEFT JOIN dbo.MM_Material AS MM
					ON MM.IdMaterial = PD.IdMaterial
				LEFT JOIN dbo.PV_TipoMoneda AS MO
					ON MO.IdMoneda = PD.IdMoneda
				LEFT JOIN dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI
					ON APDI.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
				LEFT JOIN Adinco.dbo.CO_Instalacion AS INS
						ON INS.IdInstalacion = APDI.IdInstalacion
				LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS LP 
						ON LP.IdLineaPresupuestoMes = APDI.IdLineaPresupuesto
			WHERE AP.IdAceptacionPedido = @IdAceptacionPedido;
    --END


end
