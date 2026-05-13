
CREATE PROCEDURE [dbo].[sp_BI_LlenaTabla_BI_Pedido]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AprobadoresPedido TABLE
    (
        IdPedido INT,
        AprobadorActual VARCHAR(MAX),
        NoSecuenciaInicial INT
    );

    DECLARE @Aprobadores TABLE
    (
        IdPedido INT,
        AprobadorActual VARCHAR(MAX),
        NoSecuencia INT,
        IdTipoFlujo INT
    );

    DECLARE @PedidoDetalle TABLE
    (
        ID_Bi_Pedido INT,
        IdPedido INT,
        NoPartidaDetalle INT
    );

    DECLARE @PedidoPrecioDLS AS TABLE
    (
        IdPedido INT,
        PrecioDolar FLOAT
    );

	/*CREAR TABLAS AUXILIZARES*/
	DECLARE @PedidoMontos AS TABLE (
	IdPedido INT,
	TotalPedido MONEY,
	TotalAceptado MONEY
	)

    DECLARE @Proveedores TABLE
    (
        IdProveedor INT
    );

	/*CREAR TABLAS AUXILIZARES*/
	DECLARE @Pedidos AS TABLE (
	IdPedido INT,
	EstaCerrado VARCHAR(MAX)
	)

	DECLARE @PedidoDetalleCantidadRestante AS TABLE (
	IdPedido INT,
	IdPedidoDetalle INT,
	CantidadRestante FLOAT,
	SubtotalAceptado MONEY
	)

	DECLARE @PedidosCantidadRestante AS TABLE (
	IdPedido INT,
	CantidadMaterialesRestantes FLOAT  
	)


    INSERT INTO @Proveedores
    (
        IdProveedor
    )
    VALUES	
	(606),
    (676),
    (690),
    (1315),
    (1424),
    (1835);

    DECLARE @PedidoRechazado TABLE
    (
        IdPedido INT,
        IdOperacion INT,
        FechaRechazo DATETIME
    );

    --CONSULTAR APROBADORES DE PEDIDOS 
    INSERT INTO @Aprobadores
    (
        IdPedido,
        AprobadorActual,
        NoSecuencia,
        IdTipoFlujo
    )
    SELECT P.IdPedido,
           U.Nombre,
           TA.NoSecuencia,
           FT.IdTipoFlujo
    FROM @Proveedores PS
        JOIN MM_Pedido AS P (NOLOCK)
            ON PS.IdProveedor = P.IdProveedorCompras
        JOIN dbo.TA_Operacion TAO (NOLOCK)
            ON P.IdSolicitudPedido = TAO.IdDocumento
               AND P.Version = TAO.NoVersion --> LA VERSION DEL PEDIDO DEBE SER IGUAL AL DE LA APROBACIÓN DE PEDIDO  
               AND TAO.IdTipoOperacion = 9 --> APROBACIÓN DE TIPO PEDIDO 
               AND TAO.IdEstatusOperacion = 1 --> EN APROBACIÓNES DE PEDIDO EN APROBACIÓN   
        JOIN dbo.TA_Tarea TA (NOLOCK)
            ON TAO.IdOperacion = TA.IdOperacion
               AND TA.IdEstatus = 1 --> ESTATUS DE APROBADORES EN APROBACIÓN
               AND TA.Activo = 1 --> APROBADOR ACTIVO
        JOIN dbo.TA_FlujoTarea FT (NOLOCK)
            ON FT.IdFlujoTarea = TAO.IdFlujoTarea
        JOIN dbo.S_Usuario U (NOLOCK)
            ON U.IdUsuario = TA.IdAprobador;

    --AGREGAR APROBADORES SERIALES --> OBTENER EL DE MENOR SECUENCIA 
    INSERT INTO @AprobadoresPedido
    (
        IdPedido,
        AprobadorActual,
        NoSecuenciaInicial
    )
    SELECT A.IdPedido,
           '',
           MIN(A.NoSecuencia)
    FROM @Aprobadores A
    WHERE A.IdTipoFlujo = 1 --> --> FLUJO SERIAL 
    GROUP BY A.IdPedido;

    UPDATE AP
    SET AP.AprobadorActual = A.AprobadorActual
    FROM @AprobadoresPedido AP
        INNER JOIN @Aprobadores A
            ON AP.IdPedido = A.IdPedido
               AND AP.NoSecuenciaInicial = A.NoSecuencia;

    --OBTENER LOS APROBADORES PARALELOS CONCATENADOS 
    INSERT INTO @AprobadoresPedido
    (
        IdPedido,
        AprobadorActual,
        NoSecuenciaInicial
    )
    SELECT A.IdPedido,
           (
               SELECT STUFF(
                      (
                          SELECT ', ' + AI.AprobadorActual
                          FROM @Aprobadores AI
                          WHERE A.IdPedido = AI.IdPedido
                          ORDER BY AI.NoSecuencia ASC
                          FOR XML PATH('')
                      ),
                      1,
                      2,
                      ''
                           )
           ),
           0
    FROM @Aprobadores A
    WHERE A.IdTipoFlujo = 2 --> FLUJO PARALELO
    GROUP BY A.IdPedido;

    --OBTENER FECHA DE APROBACIÓN DE PEDIDO RECHAZADOS 
    INSERT INTO @PedidoRechazado
    (
        IdPedido,
        IdOperacion
    )
    SELECT P.IdPedido,
           TAO.IdOperacion
    FROM @Proveedores PS
        JOIN MM_Pedido AS P (NOLOCK)
            ON PS.IdProveedor = P.IdProveedorCompras
        JOIN dbo.TA_Operacion TAO (NOLOCK)
            ON P.IdSolicitudPedido = TAO.IdDocumento
               AND P.Version = TAO.NoVersion --> LA VERSION DEL PEDIDO DEBE SER IGUAL AL DE LA APROBACIÓN DE PEDIDO  
               AND TAO.IdTipoOperacion = 9 --> APROBACIÓN DE TIPO PEDIDO 
               AND TAO.IdEstatusOperacion = 3 --> PEDIDO ESTE CON APROBACION RECHAZADA   
    GROUP BY P.IdPedido,
             TAO.IdOperacion;

    --ACTUALIZAR FECHA DE PEDIDO RECHAZADO
    UPDATE PR
    SET PR.FechaRechazo = T.FechaCambioEstatus
    FROM @PedidoRechazado PR
        JOIN dbo.TA_Tarea T (NOLOCK)
            ON T.IdOperacion = PR.IdOperacion
    WHERE T.IdEstatus = 3; --> OBTENER APROBADOR QUE RECHAZO EL PEDIDO YA QUE EL TIENE LA FECHA DE RECHAZO
	
    TRUNCATE TABLE BI_Pedido;
    INSERT INTO BI_Pedido
    (
        IdPedido,
        IdSolicitudPedido,
        FechaPedido,
        RazonSocial,
        MaterialCotizadoTextoC,
        MaterialCotizadoTextoL,
        Nombre,
        NumeroPedido,
        EstatusPedido,
        IdSolicitudPedidoDetalle,
        Cantidad,
        UnidadProveedor,
        PrecioUnitario,
        Subtotal,
        AprobadorActual,
        FechaAprobado,
        FechaEntregaInicial,
        FechaEntregaFinal,
        ConfirmacionPedido,
        DiasCredito,
        Moneda,
        Contrato,
        Corporativo,
        Periodo,
        Instalacion,
        FechaRechazo,
        NoPartidaDetalle,
        DescripcionGralReq,
        Solicitante,
        PartidaReq,
        PartidaDetalleReq,
		ObservacionPartidaReq,
		PedidoCerrado,
		Presupuesto,
		Tarea,
		Modelo,
		Marca,
		NumeroParte,
		CentroCosto		
    )
    SELECT P.IdPedido AS 'idpedido unico',
           S.IdSolicitudPedido AS 'idunico de requisicion',
           P.CreadoEl AS 'Fecha de pedido',
           Pr.RazonSocial AS 'Proveedor',
           POD.MaterialCotizadoTextoC AS 'Concepto',
           POD.MaterialCotizadoTextoL AS 'Descripción',
           U.Nombre AS 'Comprador',
           PS.IdPedido AS 'Numero de Pedido',
           ES.Nombre AS 'Estatus Pedido',
           SPD.IdSolicitudPedidoDetalle AS 'Partida',
           PD.Cantidad AS 'Cantidad',
           POD.UnidadProveedor AS 'Unidad',
           CAST(PD.PrecioUnitario AS MONEY) AS 'Precio Unitario',
           CAST(PD.Subtotal AS MONEY) AS 'Subtotal',
           ISNULL(APA.AprobadorActual, '') AS 'Aprobador actual',
           CAST(P.FechaEnvioPedido AS DATE) AS 'Fecha Aprobado',
           CAST(S.FechaEntregaRequerida AS DATE) AS 'Fecha Entrega Inicial',
           ISNULL(CAST(S.FechaEntregaFinRequerida AS DATE), CAST(S.FechaEntregaRequerida AS DATE)) AS 'Fecha Entrega Final',
           CASE
               WHEN P.RecepcionServicio = 1 THEN
                   'Confirmación Aceptada'
               WHEN P.RecepcionServicio = 0 THEN
                   'Confirmación Rechazada'
               WHEN P.RecepcionServicio IS NULL
                    AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0
                    AND TAO.IdEstatusOperacion = 2 THEN
                   'Confirmación Vencida '
               WHEN P.RecepcionServicio IS NULL
                    AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0
                    AND TAO.IdEstatusOperacion = 2 THEN
                   'En Confirmación'
               ELSE
                   'Confirmación No Iniciada '
           END AS 'Confirmación Pedido',
           CASE
               WHEN PD.IdCondicionPago = 1 THEN ---> CREDITO  
                   CONCAT(   PD.DiasCredito,
                             ' ',
                             CASE
                                 WHEN PD.DiasCredito = 1 THEN
                                     'día'
                                 ELSE
                                     'días'
                             END,
                             ' de ',
                             CP.CondicionPago
                         )
               ELSE
                   CP.CondicionPago
           END AS 'Dias de Credito', --> DIAS DE CREDITO ESTAN POR DETALLE DE CADA MATERIAL DEL PEDIDO
           TM.TipoMonedaCorto AS 'Moneda',
           CO.NumeroContrato AS 'Contrato',
           COR.RazonSocial AS 'Corporativo',
           PCO.NombrePeriodo AS 'Periodo',
           INS.NombreInstalacion AS 'Nombre Instalacion',
           PRZ.FechaRechazo,
           PD.IdPedidoDetalle,
           S.MotivoUrgencia AS 'Descripcion pedido',
           UR.Nombre AS 'Solicitante',
           MM.DescripcionCorta AS 'Partida requisicion',
           MM.DescripcionLarga AS 'Partida requisicion detalle',
		   SPD.observaciones AS 'Observacion detalle requisicion',
		   CASE WHEN ISNULL(P.Cerrado,0)=0 THEN 
		   'No'
		   ELSE 
		   'Si'
		   END AS 'Pedido cerrado',
		   PRE.Nombre, -->PRESUPUESTO
		   TP.id_Tarea, -->TAREA
		   MM.Modelo,
		   MM.Marca,		  
		   MM.NumeroParte,
		   CC.CentroCosto		  
    FROM @Proveedores PC
        JOIN dbo.S_Proveedor AS COR (NOLOCK)
            ON PC.IdProveedor = COR.IdProveedor
        JOIN MM_Pedido AS P (NOLOCK)
            ON PC.IdProveedor = P.IdProveedorCompras
        JOIN MM_Pedidos AS PS (NOLOCK)
            ON P.IdPedido = PS.IdIdentificador
               AND P.IdProveedorCompras = PS.IdProveedorCliente
			   AND PS.IdTipoPedido NOT IN (1,7)	   --> EXCLUIR COMPRAS DIRECTAS 1 Y COMPROBANTE EXTRANJERO 7
        JOIN dbo.TA_Operacion AS TAO (NOLOCK)
            ON P.IdSolicitudPedido = TAO.IdDocumento
               AND P.Version = TAO.NoVersion --> LA VERSION DEL PEDIDO DEBE SER IGUAL AL DE LA APROBACIÓN DE PEDIDO  
               AND TAO.IdTipoOperacion = 9 --> APROBACIÓN DE TIPO PEDIDO    
        JOIN MM_HorasVigenciaPedido AS HV (NOLOCK)
            ON P.IdPedido = HV.IdPedido
        JOIN dbo.TA_Estatus AS ES (NOLOCK)
            ON TAO.IdEstatusOperacion = ES.IdEstatus
        JOIN MM_PeticionOferta AS O (NOLOCK)
            ON P.IdPeticionOferta = O.IdPeticionOferta
        JOIN MM_SolicitudPedido AS S (NOLOCK)
            ON P.IdSolicitudPedido = S.IdSolicitudPedido
               AND O.IdSolicitudPedido = S.IdSolicitudPedido
        JOIN S_Proveedor AS Pr (NOLOCK)
            ON P.IdSubcontratista = Pr.IdProveedor
        JOIN S_Usuario AS U (NOLOCK)
            ON P.CreadoPor = U.IdUsuario
        JOIN dbo.S_Usuario AS UR (NOLOCK)
            ON S.IdUsuarioSolicitante = UR.IdUsuario
        JOIN MM_PedidoDetalle AS PD (NOLOCK)
            ON P.IdPedido = PD.IdPedido
        JOIN PV_MM_MaterialUnidad AS Un (NOLOCK)
            ON PD.IdUnidadProveedor = Un.IdUnidad
        JOIN PV_TipoMoneda AS TM (NOLOCK)
            ON PD.IdMoneda = TM.IdMoneda
        JOIN dbo.MM_PeticionOfertaDetalle AS POD (NOLOCK)
            ON O.IdPeticionOferta = POD.IdPeticionOferta
               AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
        JOIN MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
            ON S.IdSolicitudPedido = SPD.IdSolicitudPedido
               AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
        JOIN MM_Material AS MM (NOLOCK)
            ON MM.IdMaterial = SPD.IdMaterial
        JOIN MM_SolicitudPedidoDetalleLineaPresupuesto AS SPL (NOLOCK)
            ON SPD.IdSolicitudPedidoDetalle = SPL.IdSolicitudPedidoDetalle
		JOIN CC_CentroCosto AS CC (NOLOCK)
			ON SPL.IdCentroCosto=CC.IdCentroCosto
        JOIN Adinco.dbo.CO_Instalacion AS INS (NOLOCK)
            ON SPL.IdInstalacion = INS.IdInstalacion
        JOIN Adinco.dbo.CO_Contrato AS CO (NOLOCK)
            ON P.IdContrato = CO.IdContrato
        LEFT JOIN Adinco.dbo.CO_Presupuesto AS PRE (NOLOCK)
            ON S.IdPresupuesto = PRE.IdPresupuesto
		LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS L (NOLOCK)
            ON SPL.IdLineaPresupuesto = L.IdLineaPresupuestoMes
		LEFT JOIN Adinco.dbo.CO_TareaPetrolera AS TP (NOLOCK)
            ON L.IdTareaPetrolera = TP.IdTareaPetrolera
        LEFT JOIN Adinco.dbo.CO_ProgramaActividad AS PA (NOLOCK)
           ON PRE.IdProgramaActividad = PA.IdProgramaActividad
        LEFT JOIN Adinco.dbo.CO_PeriodoContrato AS PCO (NOLOCK)
            ON PA.IdPeriodoContrato = PCO.IdPeriodo
        LEFT JOIN dbo.MM_CondicionPago AS CP (NOLOCK)
            ON PD.IdCondicionPago = CP.IdCondicionPago
        LEFT JOIN @AprobadoresPedido AS APA
            ON P.IdPedido = APA.IdPedido
        LEFT JOIN @PedidoRechazado AS PRZ
            ON P.IdPedido = PRZ.IdPedido
    WHERE P.IdEliminado IS NULL --> SOLO PEDIDO ACTIVOS 
    GROUP BY P.IdPedido,
             PD.IdPedido,
             PD.IdPedidoDetalle,
             INS.IdInstalacion,
             S.IdSolicitudPedido,
             P.CreadoEl,
             Pr.RazonSocial,
             U.Nombre,
             PS.IdPedido,
             ES.Nombre,
             SPD.IdSolicitudPedidoDetalle,
             POD.MaterialCotizadoTextoC,
             PD.Cantidad,
             Un.Unidad,
             PD.DiasCredito,
             PD.PrecioUnitario,
             PD.Subtotal,
             S.FechaEntregaFinRequerida,
             S.FechaEntregaRequerida,
             TM.TipoMonedaCorto,
             CO.NumeroContrato,
             P.FechaEnvioPedido,
             P.RecepcionServicio,
             HV.FechaVigencia,
             TAO.IdEstatusOperacion,
             POD.MaterialCotizadoTextoL,
             POD.UnidadProveedor,
             P.IdEstatusEliminado,
             PD.IdCondicionPago,
             CP.CondicionPago,
             APA.AprobadorActual,
             COR.RazonSocial,
             PCO.NombrePeriodo,
             INS.NombreInstalacion,
             PRZ.FechaRechazo,
             S.MotivoUrgencia,
             UR.Nombre,
             MM.DescripcionCorta,
             MM.DescripcionLarga,
			 SPD.observaciones,
			 P.Cerrado,
			 TP.id_Tarea,
			 PRE.Nombre,
			 MM.Modelo,
			 MM.Marca,
			 MM.NumeroParte,
			 CC.CentroCosto

    ---OBTENER EL NUMERO DE PARTIDA POR DETALLE ENUMERADO DE 1 A N

    INSERT INTO @PedidoDetalle
    (
        ID_Bi_Pedido,
        IdPedido,
        NoPartidaDetalle
    )
    SELECT ID_BI_Pedido,
           IdPedido,
           ROW_NUMBER() OVER (PARTITION BY IdPedido ORDER BY NoPartidaDetalle)
    FROM dbo.BI_Pedido
    GROUP BY ID_BI_Pedido,
             IdPedido,
             NoPartidaDetalle
    ORDER BY IdPedido;

    UPDATE P
    SET P.NoPartidaDetalle = PD.NoPartidaDetalle
    FROM dbo.BI_Pedido P
        JOIN @PedidoDetalle PD
            ON P.ID_BI_Pedido = PD.ID_Bi_Pedido;

    --OBTENER EL TOTAL DEL PEDIDO
	INSERT INTO @PedidoMontos(IdPedido,TotalPedido)
	SELECT IdPedido,
	SUM(Subtotal)
	FROM BI_Pedido
	GROUP BY IdPedido

	--ACTUALIZAR EL MONTO DEL TOTAL DEL PEDIDO
	UPDATE P
    SET P.TotalPedido = PM.TotalPedido,
	P.TotalPedidoAceptado=0
    FROM dbo.BI_Pedido P
    LEFT JOIN @PedidoMontos PM
            ON P.IdPedido = PM.IdPedido;  

    --OBTENER EL PRECIO DEL USD POR PEDIDO QUE ESTAN EN MXN
    INSERT INTO @PedidoPrecioDLS
    (
        IdPedido,
        PrecioDolar
    )
    SELECT P.IdPedido,
           TC.TipoCambio
    FROM BI_Pedido AS P
        JOIN Adinco.dbo.CO_TipoCambioDiario AS TC (NOLOCK)
            ON  CAST(P.FechaPedido AS DATE) = TC.Fecha
    WHERE P.Moneda = 'MXN'
          AND TC.IdMoneda = 1 --> USD
	GROUP BY 
	P.IdPedido,
    TC.TipoCambio

    --CONVERTIR PESOS A DOLARES SEGUN EL TIPO DE MONEDA DEL PEDIDO

    UPDATE P
    SET P.SubtotalUSD = (CASE
                             WHEN P.Moneda = 'MXN' THEN
                                 P.Subtotal/PDLS.PrecioDolar  
                             ELSE
                                 Subtotal
                         END
                        )
    FROM dbo.BI_Pedido P
        LEFT JOIN @PedidoPrecioDLS PDLS
            ON PDLS.IdPedido = P.IdPedido;    

	/*ACTUALIZAR LA COLUMNA DE PEDIDO CERRADO PARA LOS PEDIDOS QUE ESTEN RECEPCIONADOS AL 100%*/
	/*OBTENER LOS PEDIDOS QUE NO ESTEN CERRADOS DE LA TABLA DE BI_PEDIDO (ESTOS YA ESTAN CLASIFICADOS ARRIBA)*/
	INSERT INTO @Pedidos
	(IdPedido,EstaCerrado)	
	SELECT IdPedido, PedidoCerrado
	FROM dbo.BI_Pedido 	
	GROUP BY IdPedido,PedidoCerrado

	/*OBTENER LAS CANTIDADES RESTANTES DE LOS PEDIDOS DETALLE (PEDIDO DETALLE - ACEPTACIONES PEDIDO DETALLE )*/
	INSERT INTO @PedidoDetalleCantidadRestante
	(
	    IdPedido,
	    IdPedidoDetalle,
	    CantidadRestante,
		SubtotalAceptado
	)	
	SELECT P.IdPedido,
           PD.IdPedidoDetalle,
           CASE WHEN P.EstaCerrado='Si' THEN 0 ELSE PD.Cantidad - SUM(ISNULL(APD.Cantidad, 0)) END, --> SI ESTA CERRADO POR DEFAULT LA CANTIDAD RESTANTE PASA A SER 0 POR QUE YA NO SE PIENSA RECIBIR ESE MATERIAL
		   PD.PrecioUnitario*SUM(ISNULL(APD.Cantidad, 0)) 
    FROM @Pedidos P
        JOIN dbo.MM_PedidoDetalle AS PD (NOLOCK)
            ON P.IdPedido = PD.IdPedido
        LEFT JOIN dbo.MM_AceptacionPedido AS AP (NOLOCK)
            ON P.IdPedido = AP.IdPedido
               AND ISNULL(AP.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO        
        LEFT JOIN dbo.MM_AceptacionPedidoDetalle AS APD (NOLOCK)
            ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
               AND PD.IdPedidoDetalle = APD.IdPedidoDetalle
    GROUP BY P.IdPedido,
             PD.IdPedidoDetalle,
			 PD.PrecioUnitario,
			 P.EstaCerrado,
             PD.Cantidad;
	
	/*AGRUPAR LAS CANTIDADES RESTANTES POR PEDIDO Y EL PEDIDO QUE TENGA UNA CANTIDAD RESTANTE IGUAL A 0 
	QUIERE DECIR QUE TODOS SUS PRODUCTOS YA HAN SIDO RECEPCIONADOS POR LO TANTO PASAN A ESTAR CERRADOS
	SI POR ALGO SALE UN NUMERO NEGATIVO PASARLO A 0*/

	INSERT INTO @PedidosCantidadRestante
	(
	    IdPedido,
	    CantidadMaterialesRestantes
	)
	SELECT IdPedido, SUM(CASE WHEN CantidadRestante<0 THEN 0 ELSE CantidadRestante END) 
	FROM @PedidoDetalleCantidadRestante
	GROUP BY IdPedido

	/*ACTUALIZAR LA COLUMNA PedidoCerrado DE BI_PEDIDOS SI LA CANTIDAD RESTANTE DEL PEDIDO ES IGUAL A 0*/	  
	UPDATE P
	SET P.PedidoCerrado='Si'
	FROM dbo.BI_Pedido P
	JOIN @PedidosCantidadRestante PCR
	ON P.IdPedido=PCR.IdPedido
	WHERE PCR.CantidadMaterialesRestantes=0
	
	/*OBTENER EL TOTAL DEL PEDIDO ACEPTADO*/
	DELETE @PedidoMontos
	INSERT INTO @PedidoMontos(IdPedido,TotalAceptado)
	SELECT IdPedido,
	SUM(SubtotalAceptado)
	FROM @PedidoDetalleCantidadRestante
	GROUP BY IdPedido

	--ACTUALIZAR EL MONTO DEL TOTAL DEL PEDIDO
	UPDATE P
    SET P.TotalPedidoAceptado = ISNULL(PM.TotalAceptado,0)
    FROM dbo.BI_Pedido P
    JOIN @PedidoMontos PM
            ON P.IdPedido = PM.IdPedido; 

END;